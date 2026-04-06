# NixOS Test Driver Manual

The NixOS integration test driver is a framework for orchestrating networks of virtual machines for testing purposes.
The [nixpkgs](https://github.com/nixos/nixpkgs) project, the biggest open source package collection in the world, uses it with [more than a thousand tests](https://github.com/NixOS/nixpkgs/tree/master/nixos/tests) to check packages and NixOS services.

## Original Manual

As the NixOS test driver belongs to the nixpkgs repository, it is also documented there in the [NixOS manual](https://nixos.org/nixos/manual), section [NixOS Tests](https://nixos.org/manual/nixos/stable/#sec-nixos-tests)

The official manual is complete and serves as a reference guide. This manual, on the other hand, is opinionated and more hands-on, designed to help beginners get started quickly.

## Features

<div class="grid cards" markdown>

-   :material-server-network:{ .lg .middle } __Describe and run networks of computers__

    ---

    Deploy to local or remote NixOS systems, even from macOS, with automatic remote building support.

    [:octicons-arrow-right-24: command reference](commands/index.md)

-   :material-shield-lock:{ .lg .middle } __Safety First__

    ---

    Prevent SSH lockouts, broken sudo permissions, and configuration errors before they
    happen with comprehensive pre-deployment checks for SSH access, sudo/wheel permissions,
    boot loader/disk space, service configs, and security settings.

    [:octicons-arrow-right-24: Security Checks](checks/index.md)

-   :material-monitor-dashboard:{ .lg .middle } __System Health__

    ---

    Monitor updates, service status, and reboot requirements across all your systems.

    [:octicons-arrow-right-24: Monitoring](commands/status.md)

-   :material-cog:{ .lg .middle } __Zero Configuration__

    ---

    Works with vanilla NixOS configurations - no special code or extra files needed.
    Automatically handles all the complexities that `nixos-rebuild` requires manual
    configuration for.

-   :material-eye:{ .lg .middle } __Fancy Optics__

    ---

    Enjoy a polished user experience with real-time build progress and output
    thanks to [`nix-output-monitor`](https://github.com/maralorn/nix-output-monitor)
    integration (when available).

</div>