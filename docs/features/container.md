# Containers in tests

!!! warning "Special host setup necessary"

    See [host configuration](#host-configuration) on this page.

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

## Host configuration

To enable the containers feature in the NixOS test driver, the Nix daemon needs to be configured properly:

=== "NixOS"

    On NixOS, add the following settings to the system configuration:

    ```nix title="configuration.nix"
    {
      nix.settings.auto-allocate-uids = true;

      nix.settings.experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];

      nix.settings.extra-system-features = [
        "uid-range"
      ];
    }
    ```

    Make sure to rebuild your system, which restarts the Nix daemon with the new settings.

=== "Non-NixOS"

    Add the following lines to the Nix daemon configuration (if these lines already exist, make sure to merge the new values with the old ones):

    ``` title="/etc/nix/nix.conf"
    auto-allocate-uids = true
    experimental-features = nix-command flakes auto-allocate-uids cgroups
    extra-system-features = uid-range
    ```

    Make sure to reload the Nix daemon after applying these settings:

    ```console
    sudo systemctl restart nix-daemon.service
    ```


### VM ↔ container network communication

Another extra setting is necessary to allow for network communicaton between VMs and containers.

??? warning "Security implications"

    As this setting gives sandbox users access to `/dev/net`, this might impede sandbox security.

=== "NixOS"

    On NixOS, add the following settings to the system configuration:

    ```nix title="configuration.nix"
    {
      nix.settings.extra-sandbox-paths = [
        "/dev/net"
      ];
    }
    ```

    Make sure to rebuild your system, which restarts the Nix daemon with the new settings.

=== "Non-NixOS"

    Add the following lines to the Nix daemon configuration (if these lines already exist, make sure to merge the new values with the old ones):

    ``` title="/etc/nix/nix.conf"
    extra-sandbox-paths = /dev/net
    ```

    Make sure to reload the Nix daemon after applying these settings:

    ```console
    sudo systemctl restart nix-daemon.service
    ```
