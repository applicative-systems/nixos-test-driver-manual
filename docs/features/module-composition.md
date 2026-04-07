# Test modules and defaults

A test is typically defined as an attribute set (See also the [minimal example](../tutorials/minimal.md)).
Outside of nixpkgs, the [`pkgs.testers.runNixOSTest`](https://nixos.org/manual/nixos/stable/#sec-call-nixos-test-outside-nixos) function calls either an attribute set directly or a file that contains such an attribute set.

Inside the test attribute set, the rules of the [NixOS module system](https://nixos.org/manual/nixos/stable/#sec-writing-modules) apply.

## Defaults

The top-level attribute set `defaults` (see also [official NixOS manual](https://nixos.org/manual/nixos/stable/#test-opt-defaults)) accepts a NixOS configuration snippet and applies it to all nodes.

Let's imagine a test with many nodes where it is desirable that they all share some common configuration, like a disabled firewall.

Instead of setting `networking.firewall.enable = false;` in every node configuration, we can set it in `defaults`:

```nix title="test.nix"
{
  name = "some test";

  nodes = {
    machine1 = { };
    machine2 = { };
    machine3 = { };
  };

  defaults = {
    networking.firewall.enable = false;
  };

  testScript = ''
    # some testing
  '';
}
```

Everything that is set in `defaults` will be merged into every node's configuration.

## Imports composition

A test module can import another test module:

```nix title="test-generic.nix"
{
  name = "some test";

  nodes.machine = {
    # some configuration
    networking.firewall.enable = true; # this is also the NixOS default
  };

  testScript = ''
    # some testing
  '';
}
```

Whatever this test does, it works with the firewall being enabled in the test VM.

To run the same test but with disabled firewall, we can write the following:

```nix title="test-without-firewall.nix"
{
  imports = [
    ./test-generic.nix
  ];

  nodes.machine = { lib, ... }: {
    networking.firewall.enable = lib.mkForce false;
  };
}
```

Running `pkgs.testers.runNixOSTest test-without-firewall.nix` runs essentially the same test, but with a disabled firewall.
