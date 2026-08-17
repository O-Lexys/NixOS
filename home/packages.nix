{
  pkgs,
  zen-browser,
  prismlauncher,
  concord,
  ...
}:
{

  home.packages = with pkgs; [
    wayvnc
    android-tools
    lsfg-vk-ui
    lsfg-vk
    mapscii
    sherlock
    playerctl
    openssl
    evtest
    libinput
    scope-tui
    blender
    scrcpy
    source2viewer-cli
    cmake
    zed-editor
    uv
    lavat
    pkgs.kdePackages.kio-extras
    bandwhich
    networkmanagerapplet
    appimage-run
    activate-linux
    terminaltexteffects
    cbonsai
    dust
    sl
    iw
    tty-clock
    slurp
    wl-clipboard
    tesseract
    imagemagick
    zbar
    curl
    ffmpeg
    wl-screenrec
    kdePackages.qtwebsockets
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
    tap-plugins
    calf
    zoxide
    wget
    linuxKernel.packages.linux_5_10.v4l2loopback
    alsa-utils
    sox
    pciutils
    firefox
    vulkan-tools
    powertop
    acpi
    yazi
    gamescope
    mangohud
    v4l-utils
    zerotierone
    gitui
    spicetify-cli
    #spotify
    coolercontrol.coolercontrol-gui
    pavucontrol
    shotcut
    nbfc-linux
    xjobs
    kdePackages.ark
    antimicrox
    usbutils
    xclicker
    droidcam
    cmatrix
    pywal
    killall
    linux-wallpaperengine
    qpwgraph
    waypaper
    wofi
    lutris
    mpv
    mpvpaper
    fastfetch
    swayimg
    grimblast
    grim
    lm_sensors
    libnotify
    vesktop
    yt-dlp
    waybar
    kdePackages.dolphin
    krita
    (btop.override { cudaSupport = true; })
    discord-canary
    (discord.override {
      withEquicord = true;
      #withVencord = true;
      withOpenASAR = true;
      #withMoonlight = true;
    })
    nemo-with-extensions
    kitty
    flatpak
    libreoffice-qt-fresh
    vlc
    gpu-screen-recorder
    cliphist
    zip
    jq
    unzip
    brightnessctl
    ddcutil
    fzf
    nixd
    zenity
    nixfmt
    ripgrep
    hypridle
    concord.packages.${pkgs.system}.concord
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
    #   neovim = {
    #     enable = true;
    #     vimAlias = true;
    #     vimdiffAlias = true;
    #     withNodeJs = true;
    #     plugins = [ pkgs.vimPlugins.nvim-treesitter.withAllGrammars ];
    #   };
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
