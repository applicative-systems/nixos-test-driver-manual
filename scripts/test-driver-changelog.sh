#!/usr/bin/env bash
set -euo pipefail

SINCE="2026-03-01"
UNTIL="2027-01-01"
PATHS=(nixos/lib/test-driver nixos/lib/testing)
OUTPUT="test-driver-changelog.md"
BATCH_SIZE=100

# Detect a remote pointing at NixOS/nixpkgs.
REMOTE=$(git remote -v | awk 'tolower($0) ~ /[:\/]nixos\/nixpkgs(\.git)?[[:space:]]+\(fetch\)$/ {print $1; exit}')
if [[ -z $REMOTE ]]; then
  echo "No git remote points at NixOS/nixpkgs. Add one as 'upstream' or 'origin'." >&2
  exit 1
fi

echo "Fetching $REMOTE master, staging-next, staging..." >&2
git fetch --quiet "$REMOTE" master staging-next staging || {
  echo "fetch failed; falling back to whatever refs are local" >&2
}

# Walk master + staging-next + staging so PRs that were rebased between
# branches (their on-master SHA reattributed by GitHub) are still findable
# by their pre-rebase SHA on staging/staging-next.
REFS=()
for branch in master staging-next staging; do
  if git rev-parse --verify --quiet "$REMOTE/$branch" >/dev/null; then
    REFS+=("$REMOTE/$branch")
  fi
done

if ((${#REFS[@]} == 0)); then
  echo "Neither $REMOTE/master nor staging refs are available locally." >&2
  exit 1
fi

echo "Collecting commits between $SINCE and $UNTIL across ${REFS[*]}..." >&2

mapfile -t lines < <(
  git log "${REFS[@]}" --since="$SINCE" --until="$UNTIL" \
    --format=$'%H\t%s' -- "${PATHS[@]}" |
    awk -F'\t' '!seen[$1]++'
)

if ((${#lines[@]} == 0)); then
  echo "No commits found." >&2
  exit 0
fi

# Fast path: squash-merge commits carry the original PR# inline as
# "Subject (#NNNN)". Trust it; no API call needed and it survives rebases.
declare -A inline_pr=()
unresolved=()
for line in "${lines[@]}"; do
  sha=${line%%$'\t'*}
  subject=${line#*$'\t'}
  if [[ $subject =~ \(#([0-9]+)\)[[:space:]]*$ ]]; then
    inline_pr[${BASH_REMATCH[1]}]=1
  else
    unresolved+=("$sha")
  fi
done

# Extra pass: feature PRs merged into staging/staging-next as real merge
# commits get pruned by git log's default merge simplification, so scan
# merge commits explicitly and keep those whose merge introduced changes
# under our paths.
extra_refs=()
for branch in staging-next staging; do
  if git rev-parse --verify --quiet "$REMOTE/$branch" >/dev/null; then
    extra_refs+=("$REMOTE/$branch")
  fi
done

if ((${#extra_refs[@]} > 0)); then
  while IFS=$'\t' read -r sha subject; do
    [[ $subject =~ \(#([0-9]+)\)[[:space:]]*$ ]] || continue
    pr_num=${BASH_REMATCH[1]}
    [[ -n ${inline_pr[$pr_num]:-} ]] && continue
    if ! git diff --quiet "$sha^1" "$sha" -- "${PATHS[@]}" 2>/dev/null; then
      inline_pr[$pr_num]=1
    fi
  done < <(
    git log "${extra_refs[@]}" --merges --since="$SINCE" --until="$UNTIL" \
      --format=$'%H\t%s'
  )
fi

echo "Found ${#lines[@]} commits: ${#inline_pr[@]} via inline PR ref, ${#unresolved[@]} via GraphQL." >&2

tmp=$(mktemp)
trap 'rm -f "$tmp"' EXIT

# Slow path: batched GraphQL on commit SHA → associatedPullRequests.
resolve_sha_batch() {
  local q='query{repository(owner:"NixOS",name:"nixpkgs"){'
  local i=0 sha
  for sha in "$@"; do
    q+="c${i}:object(oid:\"$sha\"){...on Commit{associatedPullRequests(first:5){nodes{number title mergedAt url author{login}}}}}"
    i=$((i + 1))
  done
  q+='}}'
  gh api graphql -f query="$q" |
    jq -c '.data.repository | to_entries[] | .value.associatedPullRequests.nodes[]?' \
      >>"$tmp"
}

if ((${#unresolved[@]} > 0)); then
  i=0
  while ((i < ${#unresolved[@]})); do
    end=$((i + BATCH_SIZE))
    ((end > ${#unresolved[@]})) && end=${#unresolved[@]}
    resolve_sha_batch "${unresolved[@]:i:end-i}"
    i=$end
  done
fi

# Batched GraphQL on PR# → metadata, for the inline-ref fast path.
resolve_pr_batch() {
  local q='query{repository(owner:"NixOS",name:"nixpkgs"){'
  local i=0 pr
  for pr in "$@"; do
    q+="p${i}:pullRequest(number:${pr}){number title mergedAt url author{login}}"
    i=$((i + 1))
  done
  q+='}}'
  gh api graphql -f query="$q" |
    jq -c '.data.repository | to_entries[] | .value | select(. != null)' \
      >>"$tmp"
}

if ((${#inline_pr[@]} > 0)); then
  inline_pr_list=("${!inline_pr[@]}")
  i=0
  while ((i < ${#inline_pr_list[@]})); do
    end=$((i + BATCH_SIZE))
    ((end > ${#inline_pr_list[@]})) && end=${#inline_pr_list[@]}
    resolve_pr_batch "${inline_pr_list[@]:i:end-i}"
    i=$end
  done
fi

echo "Writing $OUTPUT..." >&2

jq -rs '
  map(select(.mergedAt != null))
  | unique_by(.number)
  | sort_by(.mergedAt) | reverse
  | group_by(.mergedAt[0:7]) | reverse
  | .[]
  | (
      "## \(.[0].mergedAt[0:7])",
      "",
      (.[] |
        "### #\(.number): \(.title)",
        "",
        "Contributor: [@\(.author.login)](https://github.com/\(.author.login))",
        "",
        "[view PR #\(.number)](\(.url))",
        ""
      )
    )
' "$tmp" >"$OUTPUT"

echo "Done. Wrote $OUTPUT" >&2
