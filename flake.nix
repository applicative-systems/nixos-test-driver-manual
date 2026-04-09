{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    mkdocs-flake.url = "github:applicative-systems/mkdocs-flake/click";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.mkdocs-flake.flakeModules.default
      ];
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      perSystem =
        { pkgs, config, ... }:
        let
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs = {
              deadnix.enable = true;
              nixfmt.enable = true;
              prettier.enable = true;
              shfmt.enable = true;
              statix.enable = true;
            };
          };
        in
        {
          documentation.mkdocs-root = ./.;

          formatter = treefmtEval.config.build.wrapper;

          packages = {
            test-browser = pkgs.testers.runNixOSTest ./examples/browser.nix;
            test-echo = pkgs.testers.runNixOSTest ./examples/echo;
            test-minimal = pkgs.testers.runNixOSTest ./examples/minimal.nix;
            test-multi-network = pkgs.testers.runNixOSTest ./examples/multi-network.nix;
            test-overlay = pkgs.testers.runNixOSTest ./examples/overlay.nix;
            test-ping = pkgs.testers.runNixOSTest ./examples/ping.nix;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              config.formatter
            ];
          };

          checks = config.packages // {
            formatting = treefmtEval.config.build.check inputs.self;
          };
        };
    };
}
