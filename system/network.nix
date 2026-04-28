{ ... }:
{
  networking.hostName = "Lioha";
  networking.networkmanager.enable = true;
  networking.networkmanager.plugins = [ ];
  networking.firewall.allowedTCPPortRanges = [ ];
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.allowedUDPPortRanges = [ ];
}
