{
  description = "My nix config";
  inputs = {
    concord.url = "github:chojs23/concord";
    hyprland.url = "github:hyprwm/Hyprland";
    #hyprgrass = {
    #  url = "github:horriblename/hyprgrass";
    #  inputs.hyprland.follows = "hyprland"; # критично — той самий коміт
    #};
    musnix.url = "github:musnix/musnix";
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    youtube-music = {
      url = "github:h-banii/youtube-music-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    prismlauncher = {
      url = "github:Diegiwg/PrismLauncher-Cracked";
    };
    nixcord.url = "github:FlameFlag/nixcord";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      spicetify-nix,
      nixpkgs,
      home-manager,
      zen-browser,
      youtube-music,
      noctalia,
      nixcord,
      prismlauncher,
      musnix,
      hyprland,
      concord,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      lazer-pkg = final: prev: {
        Lazer = final.callPackage ./home/localpkgs/Lazer { };
      };
      carla-patched-pkg = final: prev: {
        carla-patched = final.callPackage ./home/localpkgs/carla-patched { };
      };
      qt6ct-kde-pkg = final: prev: {
        qt6ct-kde = final.callPackage ./home/localpkgs/qt6ct-kde { };
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        config.permittedInsecurePackages = [ "electron-38.8.4" ];
        overlays = [
          lazer-pkg
          carla-patched-pkg
          qt6ct-kde-pkg
        ];
      };

      voiceAssistantEnv = pkgs.python312.withPackages (
        ps: with ps; [
          anthropic
          speechrecognition
          pyaudio
          gtts
          requests
          python-dotenv
          pip
        ]
      );
    in
    {
      packages.${system} = {
        carla-patched = pkgs.carla-patched;
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          voiceAssistantEnv
          pkgs.espeak-ng
          pkgs.sox
          pkgs.mpg123
          pkgs.alsa-utils
          pkgs.curl
          pkgs.unzip
        ];
      };

      nixosConfigurations = {
        Lioha = nixpkgs.lib.nixosSystem {
          modules = [ ./configuration.nix ];
          specialArgs = { inherit system inputs hyprland; };
        };
      };
      homeConfigurations = {
        lioha = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit
              spicetify-nix
              noctalia
              zen-browser
              youtube-music
              nixcord
              prismlauncher
              musnix
              hyprland
              concord
              ;
          };
          modules = [ ./home.nix ];
        };
      };
    };
}
