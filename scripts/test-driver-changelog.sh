#!/usr/bin/env bash
set -euo pipefail

SINCE="2026-01-01"
UNTIL="2027-01-01"
PATHS=(nixos/lib/test-driver nixos/lib/testing)
OUTPUT="test-driver-changelog.md"

echo "Collecting commits between $SINCE and $UNTIL..." >&2
commits=$(git log --since="$SINCE" --until="$UNTIL" --format=%H -- "${PATHS[@]}")

if [[ -z $commits ]]; then
  echo "No commits found." >&2
  exit 0
fi

echo "Resolving PRs for each commit..." >&2
pr_numbers=()
seen=""
for sha in $commits; do
  prs=$(gh api "repos/NixOS/nixpkgs/commits/$sha/pulls" --jq '.[].number' 2>/dev/null || true)
  for pr in $prs; do
    if [[ ",$seen," != *",$pr,"* ]]; then
      seen="$seen,$pr"
      pr_numbers+=("$pr")
    fi
  done
done

echo "Found ${#pr_numbers[@]} unique PRs. Fetching details..." >&2

tmpfile=$(mktemp)
trap 'rm -f "$tmpfile"' EXIT

for pr in "${pr_numbers[@]}"; do
  data=$(gh api "repos/NixOS/nixpkgs/pulls/$pr" \
    --jq '[.merged_at // "", .user.login, .html_url, .title, .number] | @tsv' \
    2>/dev/null || true)
  if [[ -n $data ]]; then
    echo "$data" >>"$tmpfile"
  fi
done

echo "Writing $OUTPUT..." >&2

sort -r "$tmpfile" | awk -F'\t' '
BEGIN { current_month = "" }
{
    merged_at = $1
    user      = $2
    url       = $3
    title     = $4
    number    = $5

    if (merged_at == "") next

    month = substr(merged_at, 1, 7)
    if (month != current_month) {
        if (current_month != "") print ""
        print "## " month
        print ""
        current_month = month
    }

    print "### #" number ": " title
    print ""
    print "Contributor: [@" user "](https://github.com/" user ")"
    print ""
    print "[view PR #" number "](" url ")"
    print ""
}
' >"$OUTPUT"

echo "Done. Wrote $OUTPUT" >&2
