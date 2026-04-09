# Use the right `pkgs` attribute

One of the easiest mistakes in NixOS tests is to accidentally use the host package set where the guest package set should be used.
This can work for a while, and then fail as soon as the host and guest platforms differ.

## Host `pkgs` and guest `pkgs` are not always the same

In the following example, the package used inside the VM comes from the outer `pkgs` value that builds the test on the host:

```nix title="test.nix"
# BAD example
let
  pkgs = import <nixpkgs> { };
in
pkgs.testers.runNixOSTest {
  name = "example-test";

  nodes.machine = {
    environment.systemPackages = [
      pkgs.hello # (1)
    ];
  };

  testScript = ''
    machine.succeed("hello")
  '';
}
```

1.  This `pkgs` attribute is the one from the host, not the test machine.

That is the wrong `pkgs` for `environment.systemPackages`.
It may appear to work when host and guest use the same platform, but it breaks portability and can fail during evaluation on mixed setups such as a macOS host building a Linux guest test.

## Use the node module arguments instead

Each test node already receives the correct guest package set through the module function arguments:

```nix title="test.nix"
# GOOD example
let
  pkgs = import <nixpkgs> { };
in
pkgs.testers.runNixOSTest {
  name = "example-test";

  nodes.machine = { pkgs, ... }: { # (1)
    environment.systemPackages = [
      pkgs.hello
    ];
  };

  testScript = ''
    machine.succeed("hello")
  '';
}
```

1.  In this example, we pick the test machine's `pkgs` attribute.

    It may be for a different architecture than the host or use its own overlays.

Here, the `pkgs` inside `{ pkgs, ... }: { ... }` belongs to the guest system represented by that node.
That is the package set you usually want for NixOS module options such as `environment.systemPackages`.

## Why this is better

<!-- prettier-ignore-start -->

<div class="grid cards" markdown>

- :fontawesome-solid-plane: The test stays *portable* across different host platforms.
- :chopsticks: Guest package selection can follow guest-specific overlays and configuration.
- :material-comment-question-outline: The intent is clearer: host-side code uses host `pkgs`, node configuration uses node `pkgs`.

</div>

<!-- prettier-ignore-end -->

As a rule of thumb, use outer `pkgs` for building or invoking the test itself, and use the node module's `pkgs` argument for software that should exist inside the VM.
