{ ... }:
{
  networking.hostName = "Lioha";

  boot.extraModprobeConfig = ''
    options iwlwifi uapsd_disable=1 power_save=0
  '';

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  networking.networkmanager.plugins = [ ];

  networking.wireguard.enable = true;
  networking.wg-quick.interfaces.wg0 = {
    configFile = "/home/lioha/wireguard/wg0.conf";
  };

  services.tailscale.enable = true;
  services.zerotierone.enable = true;
  services.cloudflare-warp.enable = true;

  networking.firewall = {
    enable = true;
    checkReversePath = false;

    # діагностика — постав false, коли розберешся з портами
    logRefusedPackets = true;

    allowedTCPPorts = [
      22 # ssh
      47984
      47989
      47990
      48010 # sunshine
    ];

    allowedTCPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
    ];

    allowedUDPPorts = [ 68 ];
    allowedUDPPortRanges = [
      {
        from = 1714;
        to = 1764;
      } # KDE Connect
      {
        from = 47998;
        to = 48000;
      } # sunshine
      {
        from = 8000;
        to = 8010;
      } # sunshine
    ];

    trustedInterfaces = [
      "docker0" # ізоляція docker від основних правил
      "tailscale0"
      "wg0"
      "zt+" # zerotier інтерфейси мають префікс zt
    ];

    extraCommands = ''
      iptables -I DOCKER-USER -j RETURN
    '';
  };
}
