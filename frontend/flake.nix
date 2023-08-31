{
  description = "Python application flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec
      {
        devShells.default = pkgs.mkShellNoCC {
          buildInputs = with pkgs; [ nodejs_18 ];

          shellHook = ''
           Entered frontend shell - configured node & npm are available.
          '';
        };
      }
    );
}