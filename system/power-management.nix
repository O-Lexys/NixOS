{ pkgs, ... }:

let
  user = "lioha";

  batterySaverOn = pkgs.writeShellScript "battery-saver-on" ''
    set +e
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver

    CUR=$(${pkgs.brightnessctl}/bin/brightnessctl get)
    echo "$CUR" > /run/battery-saver-brightness
    ${pkgs.brightnessctl}/bin/brightnessctl set 40% -q

    IFACE=$(${pkgs.iw}/bin/iw dev | awk '/Interface/{print $2; exit}')
    [ -n "$IFACE" ] && ${pkgs.iw}/bin/iw dev "$IFACE" set power_save on

    if [ -w /sys/module/pcie_aspm/parameters/policy ]; then
      echo powersupersave > /sys/module/pcie_aspm/parameters/policy
    fi

    ${pkgs.powertop}/bin/powertop --auto-tune

    UID_LIOHA=$(id -u ${user})
    SIG=$(ls /run/user/$UID_LIOHA/hypr 2>/dev/null | head -1)
    if [ -n "$SIG" ]; then
      sudo -u ${user} env XDG_RUNTIME_DIR=/run/user/$UID_LIOHA HYPRLAND_INSTANCE_SIGNATURE=$SIG \
        ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1"
    fi
  '';

  batterySaverOff = pkgs.writeShellScript "battery-saver-off" ''
    set +e
    ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced

    if [ -f /run/battery-saver-brightness ]; then
      VAL=$(cat /run/battery-saver-brightness)
      ${pkgs.brightnessctl}/bin/brightnessctl set "$VAL" -q
      rm -f /run/battery-saver-brightness
    fi

    IFACE=$(${pkgs.iw}/bin/iw dev | awk '/Interface/{print $2; exit}')
    [ -n "$IFACE" ] && ${pkgs.iw}/bin/iw dev "$IFACE" set power_save off

    if [ -w /sys/module/pcie_aspm/parameters/policy ]; then
      echo default > /sys/module/pcie_aspm/parameters/policy
    fi

    UID_LIOHA=$(id -u ${user})
    SIG=$(ls /run/user/$UID_LIOHA/hypr 2>/dev/null | head -1)
    if [ -n "$SIG" ]; then
      sudo -u ${user} env XDG_RUNTIME_DIR=/run/user/$UID_LIOHA HYPRLAND_INSTANCE_SIGNATURE=$SIG \
        ${pkgs.hyprland}/bin/hyprctl keyword monitor "eDP-1,1920x1080@144,0x0,1"
    fi
  '';
in
{
  environment.systemPackages = with pkgs; [
    brightnessctl
    powertop
    iw
  ];

  systemd.services.battery-saver-on = {
    description = "Windows-like Battery Saver: увімкнути";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${batterySaverOn}";
    };
  };

  systemd.services.battery-saver-off = {
    description = "Windows-like Battery Saver: вимкнути";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${batterySaverOff}";
    };
  };

  services.udev.extraRules = ''
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="0", RUN+="${pkgs.systemd}/bin/systemctl start battery-saver-on.service"
    SUBSYSTEM=="power_supply", ATTR{type}=="Mains", ATTR{online}=="1", RUN+="${pkgs.systemd}/bin/systemctl start battery-saver-off.service"
  '';
}
