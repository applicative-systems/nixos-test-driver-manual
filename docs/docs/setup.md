# Setting up NixOS Integration Tests

To get started with NixOS integration tests, you'll need the Nix package manager with flakes enabled.

## Prerequisites

- **Nix** with flake support.
- **KVM** for hardware acceleration on Linux (strongly recommended).
- **Virtualization Framework** or `apple-virt` on macOS.

## Basic Test Flake

The easiest way to define and run a test is within a `flake.nix`.

```nix title="flake.nix"
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    checks.x86_64-linux.my-test = 
      nixpkgs.lib.nixosTest {
        name = "my-test";
        nodes.machine = { pkgs, ... }: {
          environment.systemPackages = [ pkgs.hello ];
        };
        testScript = ''
          machine.wait_for_unit("multi-user.target")
          machine.succeed("hello")
        '';
      };
  };
}
```

## Running the Test

Run the test using `nix flake check`:

```bash
nix flake check
```

Or run it specifically:

```bash
nix build .#checks.x86_64-linux.my-test
```

## Running on macOS

NixOS integration tests can run on macOS (Apple Silicon) by using a Linux builder or the `apple-virt` virtualization framework. For more details, see the [macOS Guide](https://nixcademy.com/posts/running-nixos-integration-tests-on-macos/).
