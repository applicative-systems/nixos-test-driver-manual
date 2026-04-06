# Bundling Tests with a Package

It is common to define integration tests within the same Nix expression that builds a package. This ensures that every change to the package is verified by a test.

## Example: Echo Server

Suppose you have a package `echo-server` that you want to test.

```nix title="package.nix"
{ pkgs, nixpkgs }:

let
  echo-server = pkgs.writeShellScriptBin "echo-server" ''
    ${pkgs.netcat}/bin/nc -lk 8080
  '';
in
{
  inherit echo-server;

  # Define the test alongside the package
  test = nixpkgs.lib.nixosTest {
    name = "echo-server-test";
    nodes.machine = { ... }: {
      environment.systemPackages = [ echo-server ];
      systemd.services.echo-server = {
        wantedBy = [ "multi-user.target" ];
        serviceConfig.ExecStart = "${echo-server}/bin/echo-server";
      };
    };
    testScript = ''
      machine.wait_for_unit("echo-server.service")
      machine.wait_for_open_port(8080)
      machine.succeed("echo 'hello' | nc localhost 8080")
    '';
  };
}
```

## Running the Test

In your `flake.nix`, you can expose the test as a check.

```nix title="flake.nix"
{
  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.default = (import ./package.nix { 
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit nixpkgs;
    }).echo-server;

    checks.x86_64-linux.echo-server-test = (import ./package.nix {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      inherit nixpkgs;
    }).test;
  };
}
```

Now, running `nix flake check` will build both the package and run the integration test.
