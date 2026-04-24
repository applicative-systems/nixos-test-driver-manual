# Breakpoint Hook

The NixOS test driver can stop immediately when a test fails and leave the test environment available for inspection.
This is controlled by the top-level `enableDebugHook` option from the [test options reference in the NixOS manual](https://nixos.org/manual/nixos/stable/#sec-test-options-reference).

This feature is most useful for failures that are hard to reproduce in interactive mode, especially flaky tests that only fail _sometimes_ inside the sandboxed build.

## How it Works

When `enableDebugHook = true;` is set, a failing test does not exit immediately.
Instead, the driver pauses execution and prints instructions for attaching to the suspended test environment.

From there, you can:

- connect to the test driver with `telnet localhost 4444`
- connect to test machines over SSH via vsock when `sshBackdoor.enable = true;` is also enabled

Please also refer to the [NixOS manual section about the debug hook](https://nixos.org/manual/nixos/stable/#sec-test-sandbox-breakpoint).

## Minimal Setup

```nix title="test.nix"
{
  name = "test";

  nodes.machine = { };

  sshBackdoor.enable = true;
  enableDebugHook = true;

  testScript = ''
    start_all()
    machine.succeed("false") # this will fail and trigger the breakpoint hook
  '';
}
```

??? tip "New improvements regarding the VSOCK interface"

    The SSH backdoor now uses [`vhost-device-vsock`](https://github.com/rust-vmm/vhost-device/blob/main/vhost-device-vsock/README.md), which talks [AF_VSOCK](https://man7.org/linux/man-pages/man7/vsock.7.html) to the guest but terminates on a UNIX domain socket on the host.
    No extra `--option sandbox-paths /dev/vhost-vsock` is needed any longer, and untrusted users can debug sandboxed tests with the SSH backdoor.

Simply run the test as usual:

=== "Flakes"

    ```console
    nix build .#my-test
    ```

=== "Non-Flakes"

    ```console
    nix-build run-test.nix
    ```

Early in the build, the driver prints the SSH backdoor information, including the vsock addresses for the machines.
For the first VM, that is typically `vsock/3`.

The output typically looks like this:

```console
# ...
vm-test-run-test> SSH backdoor enabled, the machines can be accessed like this:
vm-test-run-test> Note: vsocks require systemd-ssh-proxy(1) to be enabled (default on NixOS 25.05 and newer).
vm-test-run-test>     machine1:  ssh -o User=root vsock-mux//build/tmpjaxpbq5p/machine1_host.socket
vm-test-run-test>     machine2:  ssh -o User=root vsock-mux//build/tmpjaxpbq5p/machine2_host.socket
# ...
```

## Attaching After a Failure

After the failure, the test output includes an `attach` command for entering the sandbox shell.
It typically looks like this:

```console
vm-test-run-test> machine: must succeed: false
vm-test-run-test> !!! Traceback (most recent call last):
vm-test-run-test> !!!   File "<string>", line 13, in <module>
vm-test-run-test> !!!     machine.succeed("false")
vm-test-run-test> !!!
vm-test-run-test> !!! RequestedAssertionFailed: command `false` unexpectedly failed
vm-test-run-test> !!! Breakpoint reached, run 'sudo /nix/store/ksr4kryl9jl2rmgyhjw9bn2divr3s2d5-attach/bin/attach 3766386'
```

Once attached, you can connect to the VM with the generated SSH configuration:

```console
ssh -o User=root vsock-mux//build/tmpjaxpbq5p/machine2_host.socket
```

You can also connect to the paused test driver with:

```console
telnet 127.0.0.1 4444
```

That is especially useful when you want to inspect the current driver state or step through the script with `pdb` after an explicit `debug.breakpoint()`.

!!! note "`sshBackdoor.enable` is intended for debugging and provides unauthenticated access to the VMs."
!!! note "The SSH backdoor is typically paired with the interactive driver, but it can also be used together with `enableDebugHook` for sandboxed failures."
!!! note "Avoid relying on `globalTimeout` while using the breakpoint hook, because the timeout may terminate the paused test before you can inspect it."
