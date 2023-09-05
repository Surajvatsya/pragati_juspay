{
  description = "pragati/backend";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake/0.4.0";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    # services-flake.url = "github:juspay/services-flake/elasticsearch";
    services-flake.url = "github:juspay/services-flake";
    euler-hs.url = "github:juspay/euler-hs";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.haskell-flake.flakeModule
        inputs.treefmt-nix.flakeModule
        inputs.process-compose-flake.flakeModule
      ];
      perSystem = { self', system, lib, config, pkgs, ... }: {
        haskellProjects.default = {
          projectRoot = ./.;
          imports = [
            inputs.euler-hs.haskellFlakeProjectModules.output
          ];
          basePackages = pkgs.haskell.packages.ghc8107;

          packages = {
            aeson.source = "1.5.6.0";
            euler-hs.source = inputs.euler-hs;
            universum.source = "1.6.1";
            servant.source = "0.18.3";
            servant-client.source = "0.18.1";
            servant-client-core.source = "0.18.1";
            servant-server.source = "0.18.1";
            http2.source = "3.0.2";
          };

          settings = {
            aeson.jailbreak = true;
            euler-hs = {
              check = false;
              jailbreak = true;
              haddock = false;
            };
            http2.check = false;
            universum = {
              jailbreak = true;
              check = false;
            };
            servant = {
              jailbreak = true;
              check = false;
            };
            servant-server = {
              jailbreak = true;
              check = false;
            };
            servant-client-core = {
              check = false;
              jailbreak = true;
            };
            servant-client = {
              check = false;
              jailbreak = true;
            };

            binary-parsers.broken = false;
            word24.broken = false;
            tinylog.broken = false;
            openapi3.broken = false;
          };

          # Development shell configuration
          devShell = {
            hlsCheck.enable = false;
          };

          # What should haskell-flake add to flake outputs?
          autoWire = [ "packages" "apps" "checks" ]; # Wire all but the devShell
        };

        treefmt.config = {
          projectRootFile = "flake.nix";

          programs.ormolu.enable = true;
          programs.nixpkgs-fmt.enable = true;
          programs.cabal-fmt.enable = true;
          programs.hlint.enable = true;

          # We use fourmolu
          programs.ormolu.package = pkgs.haskellPackages.fourmolu;
          settings.formatter.ormolu = {
            options = [
              "--ghc-opt"
              "-XImportQualifiedPost"
            ];
          };
        };

        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          # Required for elastic search
          config.allowUnfree = true;
        };

        # Default package & app.
        packages.default = self'.packages.backend;
        apps.default = self'.apps.backend;
        process-compose."elastic" = { ... }: {
          imports = [ inputs.services-flake.processComposeModules.default ];
          services.elasticsearch."es1".enable = true;
        };
        process-compose."postgres" = { ... }: {
          imports = [ inputs.services-flake.processComposeModules.default ];
          services.postgres."postgres".enable = true;
        };

        # Default shell.
        devShells.default = pkgs.mkShell {
          name = "backend";
          meta.description = "Haskell development environment";
          # See https://zero-to-flakes.com/haskell-flake/devshell#composing-devshells
          inputsFrom = [
            config.haskellProjects.default.outputs.devShell
            config.treefmt.build.devShell
          ];
          nativeBuildInputs = with pkgs; [
            just
          ];
        };
      };
    };
}
