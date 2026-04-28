# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, inputs, ... }:

let
  prime-run = pkgs.writeShellScriptBin "prime-run" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec "$@"
  '';
in 
{
  imports = [
    ./system/users.nix
    ./hardware-configuration.nix
    ./system/services.nix
    ./system/audio.nix
    ./system/hardware.nix
    ./system/fonts.nix
    ./system/zerotierone.nix
    ./system/boot.nix
    ./system/network.nix
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
  msi-ec
];

  boot.kernelModules = [ 
    "msi-ec"
    "coretemp"
    "nct6775"
    "ec_sys" 
  ];
  
  boot.kernelParams = [ 
  "ec_sys.write_support=1" 
  "acpi_enforce_resources=lax" ];
  environment.systemPackages = with pkgs; [
    nh
    pkgs.jdk8
    prime-run
    git
    temurin-bin-8
    pipewire.jack
    pulseaudio
    neovim
    tmux
    home-manager
    sshfs
    fuse3
  ];
  environment.etc."xdg/menus/applications.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
     "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
    <Menu>
      <Name>Applications</Name>
      <Directory>kde-main.directory</Directory>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <DefaultMergeDirs/>
      <Include>
        <All/>
      </Include>
    </Menu>
  '';
  networking.firewall = {
  enable = true;
  # Discord використовує ці порти для викликів
  allowedTCPPorts = [ 25565 ]; 
  allowedUDPPorts = [ 25565 ];
  allowedUDPPortRanges = [
    { from = 50000; to = 65535; }
  ];
};
  services.udev.extraRules = ''
  ACTION=="add", SUBSYSTEM=="platform", DRIVERS=="msi-ec", ATTR{fan_mode}="*", MODE="0666"
  '';
  services.flatpak.enable = true;
  services.power-profiles-daemon.enable = true;
  services.xserver.enable = true;
  services.thermald.enable = true;
  programs = {
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
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = "nix-command flakes";
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  time.timeZone = "Europe/Kyiv";
  i18n.defaultLocale = "en_US.UTF-8";
  security = {
    polkit.enable = true;
    pam = {
      services = {
        ags = { };
        sddm.enableGnomeKeyring = true;
      };
    };
  };
  system.stateVersion = "26.05";
}
