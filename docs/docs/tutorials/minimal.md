# A minimal NixOS test

The NixOS test driver makes it easy to define a minimal test that boots a machine and runs a command.

## Defining the test file

Create a file named `test.nix`:

```nix title="test.nix"
{
  name = "A minimal NixOS test";

  nodes = {
    machine = { pkgs, ... }: { 
      environment.systemPackages = [
        pkgs.hello
      ];
    };
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("hello")
  '';
}
```

## Running the test

### With flakes

The easiest way to run the test is by using a `flake.nix`:

```nix title="flake.nix"
{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    checks.x86_64-linux.minimal = 
      nixpkgs.lib.nixosTest (import ./test.nix);
  };
}
```

Run the test:

```bash
nix flake check
```

### Without flakes

You can also run the test without flakes by using `nix-build`:

```bash
nix-build -E '(import <nixpkgs> {}).nixosTest (import ./test.nix)'
```

This will build the test and run it, providing a link to the results in `./result`.
