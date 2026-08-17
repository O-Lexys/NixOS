# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  pkgs,
  inputs,
  hyprland,
  ...
}:
{
  imports = [
    inputs.noctalia.nixosModules.default
    ./moduls/nvidia.nix
    ./system/users.nix
    ./hardware-configuration.nix
    ./system/services.nix
    #./system/audio.nix
    ./system/hardware.nix
    ./system/fonts.nix
    ./system/zerotierone.nix
    ./system/boot.nix
    ./system/network.nix
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    msi-ec
    v4l2loopback
  ];

  boot.kernelModules = [
    "msi-ec"
    "coretemp"
    "nct6775"
    "ec_sys"
    "v4l2loopback"
  ];

  boot.kernelParams = [
    "ec_sys.write_support=1"
    "acpi_enforce_resources=lax"
  ];
  environment.systemPackages = with pkgs; [
    #inputs.hyprgrass.packages.${pkgs.system}.default
    speech-denoiser
    rnnoise
    rnnoise-plugin
    calf
    distrho-ports
    hybridreverb2
    eq10q
    cardinal
    lv2bm
    lv2lint
    mda_lv2
    swh_lv2
    x42-plugins
    fluida-lv2
    noise-repellent
    zam-plugins
    aether-lv2
    bolliedelayxt-lv2
    distrho-ports
    tunefish
    bslizr
    python3
    cups-pk-helper
    gnomeExtensions.cardwire-gpu-toggle
    #open-interpreter
    quickshell
    wireguard-tools
    proton-vpn-cli
    nvidia-container-toolkit
    wineWow64Packages.waylandFull
    spotify
    jdk25
    xdotool
    xclip
    #whisper-cpp
    nh
    ollama
    git
    temurin-bin-8
    pipewire.jack
    piper-tts
    portaudio
    ffmpeg
    pulseaudio
    neovim
    tmux
    home-manager
    sshfs
    fuse3
  ];
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };
  networking.wg-quick.interfaces.wg0 = {
    configFile = "/home/lioha/wireguard/wg0.conf";
  };
  networking.networkmanager.enable = true;
  networking.wireguard.enable = true;
  networking.firewall = {
    enable = true;
    checkReversePath = false;
  };
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="platform", DRIVERS=="msi-ec", ATTR{fan_mode}="*", MODE="0666"
  '';
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      features.cdi = true;
      cdi-spec-dirs = [
        "/var/run/cdi"
        "/etc/cdi"
      ];
    };
  };
  users.users.lioha.extraGroups = [
    "adbusers"
    "docker"
    "input"
  ];
  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true;
    openFirewall = true;
  };
  services.cloudflare-warp.enable = true;
  services.flatpak.enable = true;
  services.upower.enable = true;
  #services.auto-cpufreq.enable = true;
  services.udisks2.enable = true;
  services.power-profiles-daemon.enable = true;
  services.xserver.enable = true;
  services.thermald.enable = true;
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandleLidSwitchDocked = "lock";
    LidSwitchIgnoreInhibited = false;
  };
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  services.zerotierone.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  xdg.portal = {
    enable = true;
    config.common.default = "hyprland";
  };
  programs = {
    noctalia.enable = true;
    dms-shell.enable = true;
    starship = {
      enable = true;
    };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
        libxshmfence
        zlib
        libudev-zero
        glib
        libz
        libx11
        libxrandr
        libGL
        libGLU
        mesa
        libxkbcommon
        libxext
        libxrandr
        libxcursor
        libxinerama
        libxi
        libxxf86vm
        libxrender
        libxtst
      ];
    };
    neovim = {
      enable = true;
    };
    zsh.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
      package = hyprland.packages.${pkgs.system}.hyprland;
    };
    coolercontrol.enable = true;
    steam.enable = true;
    nano.enable = false;
    ssh.startAgent = true;
  };

  services.pipewire = {
    wireplumber.enable = true;
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;
  nix.extraOptions = ''
    use-xdg-base-directories = true
  '';
  services.greetd = {
    enable = true;
    restart = true;
    settings = {
      default_session = {
        user = "greeter";
        command = "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:$SHELL --asterisks --remember --remember-user-session --time";
      };
    };
  };
  security.sudo.extraRules = [
    {
      users = [ "lioha" ];
      commands = [
        {
          command = "${pkgs.systemd}/bin/systemctl start wg-quick-wg0.service";
          options = [ "NOPASSWD" ];
        }
        {
          command = "${pkgs.systemd}/bin/systemctl stop wg-quick-wg0.service";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nix.settings = {
    experimental-features = "nix-command flakes";
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  security = {
    polkit = {
      enable = true;
      extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id == "org.freedesktop.policykit.exec" &&
              action.lookup("program").endsWith("msi-fan") &&
              subject.isInGroup("wheel")) {
            return polkit.Result.YES;
          }
        });
      '';
    };
    pam = {
      services = {
        sddm.enableGnomeKeyring = true;
      };
    };
  };
  system.stateVersion = "26.05";
}
