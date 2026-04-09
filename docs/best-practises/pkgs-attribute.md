# Use the right `pkgs` attribute

excerpt from the anti-patterns book:

#import "/globals.typ": *

== Separate host and guest packages

In NixOS integration tests, it is very easy to accidentally mix host and guest packages:

#[

#show "pkgsRed": highlight(
  fill: rgb(255,200,200),
  stroke: rgb(255,200,200),
  "pkgs"
)

#show "pkgsGreen": highlight(
  fill: rgb(180,255,180),
  stroke: rgb(180,255,180),
  "pkgs"
)

#code-box-bad(
```nix
let
  pkgsRed = import nixpkgs {};
in
pkgsRed.testers.runNixOSTest {
  name = "example-test";
  nodes.machine = {
    environment.systemPackages = [
      pkgsRed.hello
    ];
  };
  testScript = ''
    machine.succeed("hello")
  '';
}
```
)

In this example, the `hello` package included in the test VM is from the `pkgs` instance of the host (highlighted in red) that orchestrates the tests -- not the test VM.

In many cases this will just work!
However, this can cause problems when the `pkgs` instance of the guest differs from that of the host.
For example, when the host is a macOS, this will result in an evaluation error.

The right way to do this is letting each VM use its own `pkgs` attribute (highlighted in green) from the module function headers:

#code-box-good(
```nix
let
  pkgsRed = import nixpkgs {};
in
pkgsRed.testers.runNixOSTest {
  name = "example-test";
  nodes.machine = { pkgsGreen, ... }: {
    environment.systemPackages = [
      pkgsGreen.hello
    ];
  };
  testScript = ''
    machine.succeed("hello")
  '';
}
```
)
]

This way, the test is portable because it is prepared to run with differing host and guest platforms.
Also, the guest packages can be modified with overlays and overrides without having to affect the host system.
