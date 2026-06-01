# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, ... }: {
  imports = [
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

  boot.kernelModules =
    [ "msi-ec" "coretemp" "nct6775" "ec_sys" "v4l2loopback" ];

  boot.kernelParams = [ "ec_sys.write_support=1" "acpi_enforce_resources=lax" ];
  environment.systemPackages = with pkgs; [
    wineWow64Packages.waylandFull
    spotify
    jdk25
    xdotool
    xclip
    whisper-cpp
    piper-tts
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
  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 9993 25565 ];
    allowedTCPPorts = [ 25565 ];
  };
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="platform", DRIVERS=="msi-ec", ATTR{fan_mode}="*", MODE="0666"
  '';
  services.flatpak.enable = true;
  #services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = true;
  services.xserver.enable = true;
  services.thermald.enable = true;
  hardware.graphics.enable = true;
  services.zerotierone.enable = true;
  hardware.enableRedistributableFirmware = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  programs = {
    starship = { enable = true; };
    nix-ld = {
      enable = true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib
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
    neovim = { enable = true; };
    zsh.enable = true;
    hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };
    coolercontrol.enable = true;
    steam.enable = true;
    nano.enable = false;
    ssh.startAgent = true;
  };

  services.pipewire = {
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
        command =
          "${pkgs.tuigreet}/bin/tuigreet --sessions ${config.services.displayManager.sessionData.desktops}/share/xsessions:${config.services.displayManager.sessionData.desktops}/share/wayland-sessions:$SHELL --asterisks --remember --remember-user-session --time";
      };
    };
  };
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  time.timeZone = "Europe/Kyiv";
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
    pam = { services = { sddm.enableGnomeKeyring = true; }; };
  };
  nixpkgs.overlays = [
    (final: prev: {
      whisper-cpp = prev.whisper-cpp.override { cudaSupport = true; };
    })
  ];
  system.stateVersion = "26.05";
}
