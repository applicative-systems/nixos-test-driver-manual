# Interactive Test Driver

One of the most powerful features of the NixOS test driver is the **interactive mode**. It allows you to run and debug your tests step-by-step.

## Starting Interactive Mode

You can launch the interactive test driver by running the `.driver` attribute of your test with the `interactive` flag.

```bash
nix run .#checks.x86_64-linux.my-test.driver -- --interactive
```

This will drop you into a Python shell (IPython) where you can interact with the VMs.

## Useful Commands

- `start_all()`: Starts all defined virtual machines.
- `machine.wait_for_unit("multi-user.target")`: Waits for a systemd unit to be active.
- `machine.succeed("command")`: Runs a command and asserts it returns 0.
- `machine.fail("command")`: Runs a command and asserts it returns non-zero.
- `machine.shell()`: Gives you an interactive shell into the VM.
- `machine.screenshot("name")`: Takes a screenshot of the VM's screen.
- `machine.log("message")`: Prints a message to the driver's log.

## Example Session

```python
# Start all VMs
start_all()

# Run a command and see the output
print(machine.succeed("hostname"))

# Open a shell to debug something
machine.shell()

# Wait for a service to start
machine.wait_for_unit("nginx.service")
```

Interactive mode is essential for developing and troubleshooting complex tests without waiting for the full test suite to run every time.
