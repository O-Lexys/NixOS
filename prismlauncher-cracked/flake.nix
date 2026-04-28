{
  description = "PrismLauncher cracked via nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }: 
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.default = pkgs.prismlauncher.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "Diegiwg";
          repo = "PrismLauncher-Cracked";
          rev = "develop"; # або конкретний commit
          hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
        };
      });
    };
}
