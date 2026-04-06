# Connecting to Nodes in Interactive Mode

When debugging a test in interactive mode, you often want to get a shell inside the virtual machine.

## Prerequisites

Start the interactive test driver as described in the [Interactive Mode](../features/interactive.md) feature guide.

```bash
nix run .#checks.x86_64-linux.my-test.driver -- --interactive
```

## Methods to Connect

### 1. Using `machine.shell()`

The simplest way is to call `machine.shell()` from the Python prompt.

```python
# From the interactive driver
machine.shell()
```

This will give you a shell into the VM. Note that this shell is piped through the driver's console and may have some limitations.

### 2. Using SSH

If you want a more robust shell (e.g., for `tmux` or complex terminal features), you can use SSH. To do this, you'll need to enable SSH on the node and forward a port.

In your test configuration:

```nix
nodes.machine = { pkgs, ... }: {
  services.openssh.enable = true;
  users.users.root.initialPassword = "root"; # Simple password for testing
};
```

You can then connect from the host to the VM's SSH port (which is usually forwarded automatically by the driver).

### 3. Using Serial Console

The driver itself uses the serial console to run commands. You can interact with it by watching the logs or by using `machine.send_key()` and `machine.wait_for_text()`.

For most debugging purposes, `machine.shell()` is the preferred method as it's quick and integrated into the driver.
