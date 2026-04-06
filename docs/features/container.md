# Container-based Tests

For many integration tests, you don't need the full power of a Virtual Machine. The NixOS test driver also supports running tests using **NixOS containers** instead of QEMU.

## Advantages

- **Faster Startup**: Containers boot significantly faster than VMs.
- **Lower Resource Usage**: No need to emulate full hardware, leading to lower CPU and RAM consumption.
- **Cheaper CI**: Reduces costs for CI platforms by consuming fewer resources.

## Limitations

- **Shared Kernel**: All containers share the host's kernel. You cannot test custom kernel modules.
- **No Hardware Emulation**: Features like block device simulation or GUI screenshots are not available.

## How to Enable Containers

You can enable container-based tests by setting `useContainers = true;` in your test definition.

```nix title="container-test.nix"
{
  name = "container-test";

  # Enable container-based testing
  useContainers = true;

  nodes.machine = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.hello ];
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("hello")
  '';
}
```

Learn more about container tests in the [Nixcademy article](https://nixcademy.com/posts/faster-cheaper-nixos-integration-tests-with-containers/).
