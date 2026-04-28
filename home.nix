{ youtube-music, noctalia, nixcord, ... }: {
  imports = [
    ./home/theme.nix
    ./home/packages.nix
    ./home/svars.nix
    ./home/general.nix
    noctalia.homeModules.default
    youtube-music.homeManagerModules.default
    nixcord.homeModules.nixcord
  ];
}
