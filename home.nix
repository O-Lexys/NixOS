{
  youtube-music,
  noctalia,
  nixcord,
  spicetify-nix,
  wayvibes,
  pkgs,
  ...
}:
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in
{
  imports = [
    wayvibes.nixosModules.default
    ./moduls/carla.nix
    ./moduls/kdeconnect.nix
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
  services.wayvibes = {
    enable = true;
    soundpack = "/home/lioha/wayvibes/soundpacks/akko_lavender_purples";
    volume = 1;
  };
  programs.spicetify = {
    enable = true;
    enabledCustomApps = with spicePkgs.apps; [ marketplace ];
  };
}
