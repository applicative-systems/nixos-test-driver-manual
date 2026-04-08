# Screenshots and OCR

!!! note "This feature is only available in [VMs](./vms.md)"

## Screenshots

![post boot getty screenshot](../assets/test-screenshots/postboot.png){ width=300 align=right }

Screenshots can be taken at any time on any VM.
The content of the screenshot is the content of the QEMU window without its frame.

As this is the raw video output, it does not matter if the VM configuration has any graphical/desktop settings at all.

## Configuring a graphical desktop

To configure a graphical default desktop based on a minimal [IceWM](https://ice-wm.org/) setting, add the following to a VM's configuration:

```nix
{
  # ...

  nodes = {
    my-graphical-vm = {

    };
  };

  # ...
}
```

<!-- prettier-ignore-start -->

- [nixos/tests/common/x11.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/common/x11.nix)
    - this test specific profile sets up a minimal [IceWM](https://ice-wm.org/) based desktop.
    - it also includes `auto.nix`
- [nixos/tests/common/auto.nix](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/common/auto.nix)
    - this module provides auto-login display manager settings for testing

<!-- prettier-ignore-end -->

## Setting the resolution

## Graphical tests in nixpkgs

The [`nixpkgs`](https://github.com/nixos/nixpkgs) project already contains these and more graphical tests.
Each test title links to its implementation for your inspiration.

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

-   [**Chromium sandbox test** :octicons-link-external-16:](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/chromium.nix)

    ![Chromium sandbox test](../assets/test-screenshots/chromium-sandbox.png)

-   [**Oracle Virtualbox test** :octicons-link-external-16:](https://github.com/NixOS/nixpkgs/tree/master/nixos/tests/virtualbox.nix)

    ![oracle virtualbox test](../assets/test-screenshots/virtualbox.png)

-   [**Openarena multiplayer test** :octicons-link-external-16:](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/openarena.nix)

    ![Openarena multiplayer test](../assets/test-screenshots/openarena.jpg)

-   [**Teeworlds multiplayer test** :octicons-link-external-16:](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/teeworlds.nix)

    ![Teeworlds multiplayer test](../assets/test-screenshots/teeworlds.png)

-   [**GNOME desktop test** :octicons-link-external-16:](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/gnome.nix)

    ![GNOME desktop test](../assets/test-screenshots/gnome.png)

-   [**Electron app Breitbandmessung test** :octicons-link-external-16:](https://github.com/NixOS/nixpkgs/blob/master/nixos/tests/breitbandmessung.nix)

    ![Breitbandmessung test](../assets/test-screenshots/breitbandmessung.png)

</div>

<!-- prettier-ignore-end -->
