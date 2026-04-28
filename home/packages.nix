{
  pkgs,
  zen-browser,
  prismlauncher,
  ...
}:
{

  home.packages = with pkgs; [
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    carla-patched
    zerotierone
    spicetify-cli
    coolercontrol.coolercontrol-gui
    pavucontrol
    shotcut
    lm_sensors
    nbfc-linux
    xjobs
    kdePackages.ark
    antimicrox
    nano
    evtest
    usbutils
    rnnoise-plugin
    xclicker
    firefox
    droidcam
    cmatrix
    pywal
    qbittorrent
    killall
    pkgs.jdk8
    linux-wallpaperengine
    qpwgraph
    waypaper
    wofi
    lutris
    mpv
    mpvpaper
    linuxKernel.packages.linux_zen.v4l2loopback
    youtube-music
    fastfetch
    swayimg
    grimblast
    lm_sensors
    libnotify
    vesktop
    cava
    yt-dlp
    calf
    waybar
    kdePackages.dolphin
    krita
    btop
    discord-canary
    nemo-with-extensions
    kitty
    ffmpeg
    flatpak
    libreoffice-qt-fresh
    vlc
    gpu-screen-recorder
    cliphist
    wl-clipboard
    zip
    jq
    unzip
    brightnessctl
    ddcutil
    fzf
    nixd
    zenity
    nixfmt-classic
    ripgrep
    hypridle
    prismlauncher.packages.${pkgs.system}.prismlauncher
  ];

  services.flameshot = {
    # Also installs/enables flameshot
    enable = true;
    settings = {
      General = {
        useGrimAdapter = true;
        # Stops warnings for using Grim
        disabledGrimWarning = true;
      };
    };
  };
  programs = {
    zsh = {
      enable = true;
    };
    noctalia-shell = {
      enable = true;
      systemd.enable = true;
    };
    starship = {
      enable = true;
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    neovim = {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;
      withNodeJs = true;
      plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
    };
    home-manager.enable = true;
    fzf = {
      enable = true;
    };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
