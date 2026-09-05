{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    mkdocs-flake.url = "github:applicative-systems/mkdocs-flake";
    mkdocs-flake.inputs.nixpkgs.follows = "nixpkgs";
    mkdocs-flake.inputs.treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.mkdocs-flake.flakeModules.default
      ];
      systems = [
        "x86_64-linux"
        # disable these archs for now. everything should just work
        # but we only have x86 CI right now anyway
        #"aarch64-linux"
        #"aarch64-darwin"
      ];
      perSystem =
        {
          pkgs,
          lib,
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
            };
          };
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

          formatter = pkgs.treefmt.withConfig {
            settings = {
              tree-root-file = "flake.nix";
              on-unmatched = "info";
              formatter = {
                nixfmt = {
                  command = lib.getExe pkgs.nixfmt;
                  includes = [ "*.nix" ];
                };
                statix = {
                  command = lib.getExe pkgs.statix;
                  options = [ "fix" ];
                  no-positional-arg-support = true;
                  includes = [ "*.nix" ];
                };
                deadnix = {
                  command = lib.getExe pkgs.deadnix;
                  options = [ "--edit" ];
                  includes = [ "*.nix" ];
                };
                prettier = {
                  command = lib.getExe pkgs.prettier;
                  options = [ "--write" ];
                  includes = [
                    "*.css"
                    "*.html"
                    "*.md"
                    "*.yml"
                  ];
                };
                shellcheck = {
                  command = lib.getExe pkgs.shellcheck;
                  includes = [ "*.sh" ];
                };
                shfmt = {
                  command = lib.getExe pkgs.shfmt;
                  options = [
                    "-w"
                    "-i"
                    "2"
                    "-s"
                  ];
                  includes = [
                    "*.sh"
                    "*.envrc"
                  ];
                };
              };
            };
          };

          packages = {
            test-browser = pkgs.testers.runNixOSTest ./examples/browser.nix;
            test-echo = pkgs.testers.runNixOSTest ./examples/echo;
            test-headscale = pkgs.testers.runNixOSTest ./examples/headscale.nix;
            test-minimal = pkgs.testers.runNixOSTest ./examples/minimal.nix;
            test-multi-network = pkgs.testers.runNixOSTest ./examples/multi-network.nix;
            test-overlay = pkgs.testers.runNixOSTest ./examples/overlay.nix;
            test-ping = pkgs.testers.runNixOSTest ./examples/ping.nix;
            test-cuda-nvidia = cudaPkgs.testers.runNixOSTest ./examples/cuda/nvidia.nix;
            test-cuda-amd = cudaPkgs.testers.runNixOSTest ./examples/cuda/amd.nix;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              config.formatter
            ];
          };

          checks = {
            formatting = config.formatter.check inputs.self;
            # not including the cuda tests because they won't
            # run everywhere
            inherit (config.packages)
              test-browser
              test-echo
              test-headscale
              test-minimal
              test-multi-network
              test-overlay
              test-ping
              ;
          };
        };
    };
}
