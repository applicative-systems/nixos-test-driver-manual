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
        {
          pkgs,
          config,
          system,
          ...
        }:
        let
          cudaPkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              (import ./examples/cuda/overlay.nix)
            ];
            config = {
              allowUnfree = true;
              cudaSupport = true;
              cudaForwardCompat = false;
              cudaCapabilities = [ "6.1" ];
            };
          };

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

          # in the future, this should not be necessary as reqs should be
          # communicated from within the test.
          addRequiredFeatures =
            reqs: drv:
            drv.overrideTestDerivation (old: {
              requiredSystemFeatures = old.requiredSystemFeatures ++ reqs;
            });
        in
        {
          documentation = {
            mkdocs-root = ./.;
            mkdocs-preBuildHook = ''
              mkdir -p .cache/plugin/social/fonts/
              cp -r ${./docs/assets/font/social-fonts-cache}/* .cache/plugin/social/fonts/
            '';
            strict = true;
          };

          formatter = treefmtEval.config.build.wrapper;

          packages = {
            test-browser = pkgs.testers.runNixOSTest ./examples/browser.nix;
            test-echo = pkgs.testers.runNixOSTest ./examples/echo;
            test-minimal = pkgs.testers.runNixOSTest ./examples/minimal.nix;
            test-multi-network = pkgs.testers.runNixOSTest ./examples/multi-network.nix;
            test-overlay = pkgs.testers.runNixOSTest ./examples/overlay.nix;
            test-ping = pkgs.testers.runNixOSTest ./examples/ping.nix;
            test-cuda-nvidia = addRequiredFeatures [ "cuda" ] (
              cudaPkgs.testers.runNixOSTest ./examples/cuda/nvidia.nix
            );
            test-cuda-amd = addRequiredFeatures [ "cuda" ] (
              cudaPkgs.testers.runNixOSTest ./examples/cuda/amd.nix
            );
          };

          devShells.default = pkgs.mkShell {
            packages = [
              config.formatter
            ];
          };

          checks = {
            formatting = treefmtEval.config.build.check inputs.self;
            # not including the cuda tests because they won't
            # run everywhere
            inherit (config.packages)
              test-browser
              test-echo
              test-minimal
              test-multi-network
              test-overlay
              test-ping
              ;
          };
        };
    };
}
