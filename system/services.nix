{ pkgs, ... }:
{
  services.gnome.gcr-ssh-agent.enable = false;
  services.usbmuxd.enable = true;
  services.dbus.enable = true;
  services.logrotate.checkConfig = false;
  systemd.services.logrotate-checkconf.enable = false;
  services.speechd.enable = false;
  services.upower = {
    enable = true;
    criticalPowerAction = "Hibernate";
  };

  systemd = {

    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };
  services.gnome.gnome-keyring.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
  systemd.services.NetworkManager-wait-online.enable = false;
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };
}
