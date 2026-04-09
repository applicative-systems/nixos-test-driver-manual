# Test Script Linting

The NixOS test driver can validate your Python `testScript` before the test is executed.
This catches common mistakes early, before resources are wasted on failures that could have been detected at build time.

## Benefits

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   :material-bug: **Early Error Detection**

    ---

    Catch obvious syntax mistakes and logic errors before starting long-running VMs or containers.

-   :material-run-fast: **Increased CI efficiency**

    ---

    Prevent trivially broken test scripts from wasting CI time and resources.

</div>

<!-- prettier-ignore-end -->

## How it Works

The `testScript` is Python code embedded in your test definition.
When the test is built, the driver runs:

- [Pyflakes](https://pypi.org/project/pyflakes/) to lint the script and catch common Python mistakes
- [mypy](https://www.mypy-lang.org/) to type-check the script

This means syntax issues, undefined names, and many type-related mistakes are reported before the test itself starts running.

## Skipping Checks During Development

For rapid local iteration, the test options reference in the [NixOS manual](https://nixos.org/manual/nixos/stable/#sec-test-options-reference) provides two escape hatches:

```nix title="test.nix"
{
  name = "my test";

  skipLint = true;      # disables the Pyflakes check
  skipTypeCheck = true; # disables the mypy check

  # ...
}
```

Both options default to `false`.

Disabling these checks can speed up rebuilds while you are changing a test frequently.
That can be useful during development, but tests with linting or type-checking disabled should generally not be committed to production repositories.
