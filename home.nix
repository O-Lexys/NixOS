{ youtube-music, noctalia, nixcord, spicetify-nix, pkgs, ... }:
let spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [
    ./moduls/obs.nix
    ./moduls/AI.nix
    ./moduls/zsh.nix
    spicetify-nix.homeManagerModules.default
    ./home/theme.nix
    ./home/packages.nix
    ./home/svars.nix
    ./home/general.nix
    noctalia.homeModules.default
    youtube-music.homeManagerModules.default
    nixcord.homeModules.nixcord
  ];
  programs.spicetify = {
    enable = true;
    theme = spicePkgs.themes.text;
    colorScheme = "Spotify";
    enabledCustomApps = with spicePkgs.apps; [ marketplace ];
  };

}
