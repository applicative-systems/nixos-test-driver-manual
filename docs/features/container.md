# Containers in tests

Test nodes can be implemented as containers Instead of [VMs](./vm.md).
These use [Systemd-nspawn](https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html) as their backend.

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   Advantages

    - **Performance**: Each container runs their own systemd process tree on the host kernel instead of virtualising a whole computer, which saves resources (memory and time).
    - **Runs in VMs**: Compared to [VM-based](./vm.md) tests, containers run very well on VM-based Nix builders, which allows for cheaper infrastructure.
    - **Share host resources**: Host resources like GPUs can be shared with test containers.
        - See also [CUDA tests in containers](../tutorials/cuda-tests.md)

-   Disadvantages

    - **No custom kernel**: Containers directly run on top of the host kernel.
    - **No GUI**: Currently not supported.
    - **No Setuid**: Software packages that require [Setuid](https://de.wikipedia.org/wiki/Setuid) support are not supported inside the Nix sandbox.

</div>

<!-- prettier-ignore-end -->

## Defining Containers

```nix title="test.nix"
{
  name = "test name";

  # All sub attributes under `containers` represent containers
  containers = {
    container1 = { };
    container2 = { };
    # ...
  };

  testScript = ''
    # ...
  '';
}
```

### Default Configuration

An empty NixOS container configuration (`{ }`) creates a VM with the usual NixOS default settings as well as:

- Sets an empty `root` password
- Disables manuals
- Disables `switch-to-configuration` tooling
- Adds a [backdoor service](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/testing/test-instrumentation.nix#L19) for test instrumentation

Most options can be re-enabled.

For all the details, refer to the [NixOS test module that assembles test node configurations](https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/testing/nodes.nix)
