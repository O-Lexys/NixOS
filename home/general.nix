{ pkgs, ... }:
{
  home = {
    username = "lioha";
    homeDirectory = "/home/lioha";
    stateVersion = "26.05";
  };
  xdg = {
    mime.enable = true;
    portal.configPackages = [ pkgs.xdg-desktop-portal-hyprland ];
  };
  wayland.windowManager.hyprland.xwayland.enable = true;
}
