# Virtual Machine (VM) Tests

VM-based tests are the standard way to run NixOS integration tests. They use QEMU to spin up one or more virtual machines running NixOS.

## Advantages

- **Full Isolation**: Each node is its own VM.
- **Custom Kernels**: You can test custom kernel modules or configurations.
- **Hardware Simulation**: Simulate network interfaces, storage devices, and more.
- **GUI Testing**: Take screenshots and perform OCR on the virtual screen.

## Example

```nix
{
  name = "VM-based test";
  nodes.machine = { ... }: {
    # NixOS configuration for the VM
  };
  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.screenshot("booted")
  '';
}
```

By default, `nixosTest` uses VMs.
