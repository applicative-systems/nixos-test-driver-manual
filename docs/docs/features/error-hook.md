# Error Hooks

The NixOS test driver provides an **error hook** mechanism to collect diagnostic information when a test fails.

## Why Use Error Hooks?

When a test fails, you often want to know what happened in the VMs. Error hooks can be used to:

- **Collect Screenshots**: Capture the state of the GUI at the moment of failure.
- **Save Logs**: Dump logs from the VM (e.g., systemd journal) to the host.
- **Diagnostic Output**: Print additional information from the driver.

## How to Implement an Error Hook

You can define an error hook in your `testScript`.

```python
# In your testScript
test_script = ''
  def on_error():
      # This function will be called when the test fails
      machine.screenshot("error")
      machine.log(machine.succeed("journalctl -u nginx.service"))

  with machine.on_error(on_error):
      machine.wait_for_unit("nginx.service")
      machine.succeed("curl http://localhost")
''
```

## Collecting Artifacts

Artifacts captured during an error hook (like screenshots) are saved in the Nix store alongside the test result.

Error hooks are a powerful way to troubleshoot failing tests, especially in automated CI environments.
