# Setting up NixOS Integration Tests

To run NixOS integration tests, you basically just need Nix and, for the best experience, KVM support.

If you wish to run NixOS integration tests on Apple macOS, please go to the [macOS section](#macos-setup).

## Prerequisites

### Baremetal GNU/Linux

Any GNU/Linux distribution works with Nix and the integration tests.

The test driver can run virtual machines (using [qemu](https://www.qemu.org/)) and containers (using [systemd-nspawn](https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html)).

The virtual machines don't always run well if Nix itself already runs inside a virtualized Linux machine.
For the best experience with VMs, use a baremetal Linux machine (The container based tests run well inside VMs).

### Linux KVM

The important bit is that [KVM](https://en.wikipedia.org/wiki/Kernel-based_Virtual_Machine) is enabled, which enables hardware-accelerated virtualization.
The tests also run without KVM but will be very slow in that case.

Check your KVM configuration:

1. Running `lsmod` should show that the `kvm` modules (with hardware platform specific `kvm_*` variants) are loaded:
   ```console
   $ lsmod | grep kvm
   kvm_amd               245760  0
   ccp                   212992  1 kvm_amd
   kvm                  1425408  1 kvm_amd
   irqbypass              16384  1 kvm
   ```
2. Check that you and the Nix build users have write-access to `/dev/kvm`:
   ```
   $ ls -l /dev/kvm
   crw-rw-rw- 1 root kvm 10, 232 Apr  6 19:18 /dev/kvm
   ```
   In this configuration, anyone has write-access to `/dev/kvm`, which is the simplest configuration method.

### Nix

The tests are all built and run with Nix.
To install Nix, run the following command (see also [Nix installer page](https://nixos.org/download/)):

```console
sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install) --daemon
```

Test your Nix installation like this:

```console
$ nix --experimental-features "nix-command flakes" run nixpkgs#hello
Hello, world!
```

## macOS setup

NixOS integration tests can run on macOS (Apple Silicon) by using a Linux builder or the `apple-virt` virtualization framework.
For more details, see the [Nixcademy NixOS test driver guide for macOS](https://nixcademy.com/posts/running-nixos-integration-tests-on-macos/).
