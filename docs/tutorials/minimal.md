# A minimal NixOS test

The NixOS test driver makes it easy to define a minimal test that boots a machine and runs a command.

## Defining the test file

Create a file named `test.nix`:

```nix title="test.nix"
--8<-- "examples/minimal.nix"
```

## Running the test

For a quick and dirty test run, we can run the test through the [`runNixOSTest` function](https://nixos.org/manual/nixos/stable/#sec-call-nixos-test-outside-nixos) on the command line:

```console
nix-build -E "(import <nixpkgs> {}).testers.runNixOSTest ./minimal.nix"
```

`runNixOSTest` returns a derivation that runs the test in the sandbox and returns its result in the output folder (typically linked to by the `result/` symlink).
For most tests, this folder is empty.

### Flake boilerplate code

If you intend to make the test part of a flake, the minimal boiler plate code would look like this:

```nix title="flake.nix"
{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.test = pkgs.testers.runNixOSTest ./minimal.nix;
    };
}
```

Run the test:

```console
nix build -L .#test
```

### Without flakes

Without flakes, the minimal code in a `release.nix` file or similar would look like this:

```nix title="run-test.nix"
let
  pkgs = import <nixpkgs> { };
in
pkgs.testers.runNixOSTest ./minimal.nix
```

Run the test:

```console
nix-build run-test.nix
```
