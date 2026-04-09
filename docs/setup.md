# Setting up NixOS Integration Tests

To run NixOS integration tests, you basically just need Nix and, for the best experience, KVM support.

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   :simple-linux: **Linux**

    ---

    The test driver can run virtual machines ([qemu](https://www.qemu.org/)) and containers ([systemd-nspawn](https://www.freedesktop.org/software/systemd/man/latest/systemd-nspawn.html)).
    For good VM performance, run a *bare-metal* instance of Linux.

-   :fontawesome-solid-apple-alt: **macOS**

    ---

    The test driver also runs on macOS.
    Only VMs are supported, not containers.

    [:octicons-arrow-right-16: See macOS setup](#macos-setup)

-   :simple-nixos: **Nix**

    ---

    Use the multi-user installation for best experience.

    [:octicons-arrow-right-16: See Nix install & check](#nix)

-   :octicons-stack-16: **KVM**

    ---

    Hardware-accelerated virtualisation makes VM tests fast.

    [:octicons-arrow-right-16: See KVM check](#linux-kvm)

</div>

<!-- prettier-ignore-end -->

## Installation and setup check

### :simple-nixos: Nix

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

If this works, you are ready to go:
Continue [writing your first minimal NixOS test here](tutorials/minimal.md)

### :octicons-stack-16: Linux KVM

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

## :fontawesome-solid-apple-alt: macOS setup

NixOS integration tests can run on macOS (Apple Silicon) by using a Linux builder or the `apple-virt` virtualization framework.
For more details, see the [Nixcademy NixOS test driver guide for macOS](https://nixcademy.com/posts/running-nixos-integration-tests-on-macos/).
