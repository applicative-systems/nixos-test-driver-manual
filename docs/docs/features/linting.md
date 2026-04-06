# Test Script Linting

The NixOS test driver includes a built-in linter to check your `testScript` for Python errors before running the test.

## How it Works

The `testScript` is a string containing Python code. When the test is built, Nix automatically runs a Python linter (like `flake8`) over the script to ensure there are no syntax errors or common pitfalls.

## Benefits

- **Early Error Detection**: Catches typos in commands or logic before starting slow VMs.
- **Improved Code Quality**: Encourages cleaner Python code in your tests.
- **CI Reliability**: Prevents broken tests from reaching your CI pipeline.

## Example Error

If you have a typo in your `testScript`:

```python
# typo.nix
testScript = ''
  machine.succeed("echo hello")
  machine.sccced("echo world") # Typo!
'';
```

Nix will fail the build with a message like:

```text
error: test script linting failed
  /nix/store/.../test-script.py:2:10: undefined name 'machine.sccced'
```

Linting is enabled by default for all NixOS integration tests.
