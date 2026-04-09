# NixOS Test Driver Manual

Opinionated, hands-on documentation for the NixOS integration test driver.

This repository contains the source for the manual published at:

- <https://applicative.systems/nixos-test-driver-manual>

The goal of this manual is to complement the [official NixOS manual](https://nixos.org/manual/nixos/stable/#sec-nixos-tests) with practical tutorials, feature guides, best practices, and runnable examples.

## What is in this repository?

- `docs/`: the MkDocs source for the published manual
- `examples/`: runnable example tests used throughout the documentation
- `flake.nix`: development, formatting, documentation, and example test outputs
- `mkdocs.yml`: site structure and theme configuration

## Read the manual

Good starting points:

- [Setup](./docs/setup.md)
- [Tutorials](./docs/tutorials/index.md)
- [Features](./docs/features/index.md)
- [Best Practices](./docs/best-practices/index.md)

## Build the documentation

Build the static site with Nix:

```console
nix build .#documentation
```

The generated site will be available through the `result/` symlink.

## Run the example tests

This repository exposes several example tests as flake packages:

```console
nix build .#test-minimal
nix build .#test-ping
nix build .#test-browser
```

For interactive debugging examples:

```console
nix build .#test-browser.driverInteractive
./result/bin/run-nixos-test
```

## Development

Enter the development shell:

```console
nix develop
```

Format the repository:

```console
nix fmt
```

## Maintainers

This manual is maintained by [Applicative Systems](https://applicative.systems).
