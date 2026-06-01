{ pkgs, zen-browser, prismlauncher, ... }: {

  home.packages = with pkgs; [
    #hyprlandPlugins.hypr-dynamic-cursors
    #hyprlandPlugins.hy3
    slurp
    wl-clipboard
    tesseract
    imagemagick
    zbar
    curl
    ffmpeg
    wl-screenrec
    kdePackages.qtwebsockets
    virtualbox
    xdg-desktop-portal-hyprland
    pipewire
    wireplumber
    rnnoise-plugin
    xkbutils
    ydotool
    anydesk
    blockbench
    freerdp
    remmina
    nvme-cli
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    upower
    auto-cpufreq
    carla-patched
    zoxide
    wget
    linuxKernel.packages.linux_5_10.v4l2loopback
    alsa-utils
    sox
    pciutils
    firefox
    usbutils
    vulkan-tools
    powertop
    acpi
    yazi
    mangohud
    v4l-utils
    zerotierone
    gitui
    spicetify-cli
    #spotify
    coolercontrol.coolercontrol-gui
    pavucontrol
    shotcut
    lm_sensors
    nbfc-linux
    xjobs
    kdePackages.ark
    antimicrox
    evtest
    usbutils
    xclicker
    droidcam
    cmatrix
    pywal
    qbittorrent
    killall
    linux-wallpaperengine
    qpwgraph
    waypaper
    wofi
    #lutris
    mpv
    mpvpaper
    fastfetch
    swayimg
    grimblast
    grim
    lm_sensors
    libnotify
    vesktop
    cava
    yt-dlp
    calf
    waybar
    kdePackages.dolphin
    krita
    (btop.override { cudaSupport = true; })
    discord-canary
    nemo-with-extensions
    kitty
    ffmpeg
    flatpak
    libreoffice-qt-fresh
    vlc
    gpu-screen-recorder
    cliphist
    osu-lazer
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
    zsh = { enable = true; };
    noctalia-shell = { enable = true; };
    starship = { enable = true; };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    #   neovim = {
    #     enable = true;
    #     vimAlias = true;
    #     vimdiffAlias = true;
    #     withNodeJs = true;
    #     plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
    #   };
    home-manager.enable = true;
    fzf = { enable = true; };
    carapace = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
