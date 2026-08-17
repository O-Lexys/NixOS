{ pkgs, lib, ... }: {
  services.kdeconnect = {
    enable = true;
    package = pkgs.kdePackages.kdeconnect-kde;
    indicator = true;
  };

  systemd.user.services.kdeconnect.Service = {
    Restart = lib.mkForce "on-failure";
    RestartSec = 3;
  };
}
