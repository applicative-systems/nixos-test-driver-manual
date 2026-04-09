# Connecting to Nodes in Interactive Mode

When a test fails, the fastest way to understand the problem is often to log into the affected VM and inspect it like a normal machine.

This is one of the main reasons to use the test driver in [interactive mode](../features/interactive.md):
We can reproduce a failing test locally, keep the machines alive, and debug them with direct shell access.

This tutorial shows two common ways to connect to nodes in interactive mode:

1. `machine.shell_interact()` for a quick shell through the driver
2. SSH over [VSOCK](https://man7.org/linux/man-pages/man7/vsock.7.html) for a more native terminal session

## Quick shell access with `machine.shell_interact()`

The simplest option is to ask the driver to attach you directly to a machine shell from the Python prompt:

```python
machine.shell_interact()
```

This opens an interactive shell inside the guest VM without any additional configuration.
It is a good fit when you want to quickly inspect files, run a few commands, or verify the current system state during test development.

!!! note

    This shell is routed through the test driver, so it is convenient but less native than a direct SSH session.
    Exiting the shell with `Ctrl-D` or interrupting it with `Ctrl-C` also ends that guest session.

## SSH access over VSOCK

For longer debugging sessions, SSH is usually more comfortable.
The test driver can expose a debugging backdoor over [VSOCK](https://man7.org/linux/man-pages/man7/vsock.7.html), so you can connect to each VM with a normal `ssh` client from the host system.
Because this uses a host-to-guest VSOCK channel, it does not depend on the VM's existing test network setup and does not require opening ports or otherwise changing the machine's regular network configuration.

This is controlled by [`sshBackdoor.enable`](https://nixos.org/manual/nixos/stable/#test-opt-sshBackdoor.enable).
When you only want this in interactive mode, enable it under the [`interactive` top-level attribute](../features/interactive.md#adding-extra-configuration-only-in-interactive-mode).

!!! note

    The SSH backdoor is intended for debugging.
    It provides unauthenticated access to the test VMs.

## Example test

The following example enables the SSH backdoor only for interactive runs:

```nix title="test.nix"
{
  name = "ssh-backdoor-example";

  interactive.sshBackdoor.enable = true;

  nodes = {
    machine1 = { };
    machine2 = { };
    machine3 = { };
  };

  testScript = ''
    start_all()
  '';
}
```

Build the interactive driver first:

=== "Flakes"

    ```console
    nix build .#test.driverInteractive
    ```

=== "Non-Flakes"

    ```console
    nix-build run-test.nix -A driverInteractive
    ```

Then start it:

```console
./result/bin/run-nixos-test
```

Early in the startup output, the driver prints the SSH commands for all machines:

```console
# ...
SSH backdoor enabled, the machines can be accessed like this:
Note: vsocks require systemd-ssh-proxy(1) to be enabled (default on NixOS 25.05 and newer).
    machine1:  ssh -o User=root vsock/3
    machine2:  ssh -o User=root vsock/4
    machine3:  ssh -o User=root vsock/5
# ...
IPython 9.9.0 -- An enhanced Interactive Python. Type '?' for help.

In [1]:
```

At this point the driver is ready, but the machines still need to be booted before SSH can work.
Start them with:

```python
start_all()
```

or run the whole test script with:

```python
run_tests()
```

After the machines are up, use the printed commands from another terminal on the host:

```console
ssh -o User=root vsock/3
```

That gives you a normal shell on the guest, which is often the most convenient way to inspect services, logs, networking, and files during debugging.

## When to use which method

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   `machine.shell_interact()`

    ---

    - You want immediate shell access from the interactive Python prompt
    - You do not need a full SSH session
    - You are doing quick exploratory debugging

-   SSH over VSOCK

    ---

    - you want a more native shell experience
    - you want to keep a separate terminal open while using the Python prompt
    - you need a more robust setup for longer debugging sessions

</div>

<!-- prettier-ignore-end -->

## Related pages

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   [:keyboard: **Interactive mode**](../features/interactive.md)

    ---

    Effortless local debugging of tests.

-   [:hook: **Breakpoint hook**](../features/error-hook.md)

    ---

    Can't reproduce rare flaky test failures? Hook into the test sandbox when it happens!


-   [:bookmark: **NixOS manual: machine methods**](https://nixos.org/manual/nixos/stable/#ssec-machine-objects)

-   [:bookmark: **NixOS manual: `sshBackdoor` setting**](https://nixos.org/manual/nixos/stable/#test-opt-sshBackdoor.enable)

</div>

<!-- prettier-ignore-end -->
