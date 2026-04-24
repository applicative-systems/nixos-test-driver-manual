# Driver Log Levels

The NixOS test driver emits a lot of output by default: progress lines for every driver action, informational notes, warnings, and error messages.
During development that is useful, but in CI — or when you just want to see what actually went wrong — the noise can bury the relevant lines.

??? example "This feature has been recently upstreamed"

    Since [PR #509867](https://github.com/NixOS/nixpkgs/pull/509867), the driver supports a configurable log level.

    If the attribute `logLevel` doesn't exist in your NixOS version, please upgrade to the latest nixpkgs.

## Available Levels

The driver distinguishes three levels.
Each level includes itself and every more severe level above it:

| Level     | Includes                   | Typical use                                    |
| --------- | -------------------------- | ---------------------------------------------- |
| `info`    | `info`, `warning`, `error` | Default. Good for local development.           |
| `warning` | `warning`, `error`         | Quieter runs; hides routine progress messages. |
| `error`   | `error` only               | Minimal output; only failure-relevant lines.   |

Serial console output from the VMs is controlled separately and is not affected by the log level.

## Setting the Log Level

### In a test definition

Use the top-level `logLevel` option in your test.
It is documented in the [NixOS manual](https://nixos.org/manual/nixos/stable/#test-opt-logLevel).

```nix title="test.nix"
{
  name = "example-test";

  logLevel = "warning";

  nodes.machine = { ... }: {
    # configuration
  };

  testScript = ''
    start_all()
  '';
}
```

The default is `"info"`.

### On the command line

The interactive driver accepts `--log-level <level>`:

```console
./result/bin/nixos-test-driver --log-level warning
```

This is handy when you want to temporarily quieten a run without editing the test or need more debug output.

## When to Use Which Level

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   :material-laptop: **`info` (default)**

    ---

    Keep the default while you are developing a test.
    Progress messages make it obvious where the driver is spending time.

-   :material-server-network: **`warning` in CI**

    ---

    Trim routine progress lines so CI logs stay focused on problems.
    Warnings and errors are still surfaced.

-   :material-bug-check: **`error` for minimal output**

    ---

    Useful for large test matrices where you only want to see which tests failed and why.

</div>

<!-- prettier-ignore-end -->
