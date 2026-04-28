{ youtube-music, noctalia, nixcord, spicetify-nix, pkgs, ... }: 
let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.system};
in {
  imports = [
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
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };
}
