# Virtual Machines in tests

VM-based tests are the standard way to run NixOS integration tests.
They use [QEMU](https://www.qemu.org/) to spin up one or more virtual machines running NixOS.

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   Advantages

    - **Full Isolation**: Each machine is its own VM.
        - Although tests typically don't run untrusted code
    - **Custom Kernels**: You can test custom kernel modules or configurations.
    - **Hardware Simulation**: Add hardware models to the system configuration.
    - **GUI Testing**: Take screenshots and perform OCR on the virtual screen.
        - See also [Screenshots and OCR](./screenshots-and-ocr.md)

-   Disadvantages

    - **Overhead**: Each VM consumes more resources (time and memory) because it simulates a whole system
    - **Virtualisation requirement**: Compared to [container-based](./container.md) tests, the Nix build host either needs to provide KVM support or the nodes will be very slow due to software virtualisation.

</div>

<!-- prettier-ignore-end -->

## Defining VMs

```nix title="test.nix"
{
  name = "test name";

  # All sub attributes under `nodes` represent QEMU VMs
  nodes = {
    machine1 = { };
    machine2 = { };
    # ...
  };

  testScript = ''
    # ...
  '';
}
```

### Default Configuration

An empty NixOS VM configuration (`{ }`) creates a VM with the usual NixOS default settings as well as:

- Sets an empty `root` password
- Disables manuals
- Disables `switch-to-configuration` tooling
- Adds a [backdoor service](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/testing/test-instrumentation.nix#L19) for test instrumentation

Most options can be re-enabled.

For all the details, refer to the [NixOS test module that assembles test node configurations](https://github.com/NixOS/nixpkgs/blob/master/nixos/lib/testing/nodes.nix)

## Configuring VMs

QEMU VM nodes also import the [`qemu-vm.nix`](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/qemu-vm.nix) profile.
The prefix `virtualisation.*` provides access to options like CPU core count, memory size, QEMU package choice, etc.

For all the options, refer to the [profile definition](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/qemu-vm.nix) or [NixOS options search](https://search.nixos.org/options?channel=unstable&query=virtualisation.).
There is also more information in the [official NixOS manual](https://nixos.org/manual/nixos/stable/#sec-nixos-test-nodes).

This example reconfigures a VM:

```nix title="test.nix"
{
  name = "test name";

  # All sub attributes under `nodes` represent QEMU VMs
  nodes = {
    machine1 = {
      virtualisation.qemu = {
        cores = 4; # CPU cores

        memorySize = 4096; # RAM - default is 1024;

        resolution = { # for VMs with graphics output
            x = 800;
            y = 600;
        };

        forwardPorts = [
          {
            from = "host";
            host.port = 2222; # forward guest SSH port to host's 2222 port
            guest.port = 22;
          }
        ];
      };
    };
  };

  testScript = ''
    # ...
  '';
}
```
