{
  description = "pragati/backend";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    haskell-flake.url = "github:srid/haskell-flake";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";
    services-flake.url = "github:juspay/services-flake/elasticsearch";
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
	  imports = [
		inputs.euler-hs.haskellFlakeProjectModules.output
	  ];
          basePackages = pkgs.haskell.packages.ghc8107;

          packages = {
            euler-hs.source = inputs.euler-hs;
          };

          settings = {
            euler-hs = {
              check = false;
              jailbreak = true;
              haddock = false;
            };
	    binary-parsers.broken = false;
	    word24.broken = false;
	    tinylog.broken = false;
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
