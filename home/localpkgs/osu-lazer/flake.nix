{
  description = "osu!lazer - official AppImage wrapped for NixOS (supports ranking/multiplayer)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          osu-lazer-bin = pkgs.callPackage ./default.nix { };
          default = osu-lazer-bin;
        };

        # Allow running directly with `nix run`
        apps = rec {
          osu-lazer-bin = flake-utils.lib.mkApp {
            drv = self.packages.${system}.osu-lazer-bin;
            name = "osu!";
          };
          default = osu-lazer-bin;
        };
      }
    ) // {
      # Overlay for use in NixOS configurations
      overlays.default = final: prev: {
        osu-lazer-bin = final.callPackage ./default.nix { };
      };
    };
}
