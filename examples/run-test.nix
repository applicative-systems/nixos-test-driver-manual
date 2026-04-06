let
  pkgs = import <nixpkgs> { };
in
pkgs.testers.runNixOSTest ./minimal.nix
