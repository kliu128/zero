{ config, lib, pkgs, ... }:

{
  networking.useNetworkd = true;
  networking.useDHCP = false; # not supported by systemd-networkd
  networking.usePredictableInterfaceNames = false;
  systemd.network.enable = true;
  services.resolved.dnssec = "false";
  systemd.network.networks = {
    "40-eth0" = {
      matchConfig = { Name = "eth0"; };
      networkConfig = {
        Bridge = "br0";
      };
    };
    "40-br0" = {
      matchConfig = { Name = "br0"; };
      networkConfig = {
        DHCP = "ipv4";
      };
      linkConfig = {
        MACAddress = "74:d4:35:e2:52:9b";
      };
    };
    "99-main" = {
      matchConfig = { Name = "*"; };
      linkConfig = { Unmanaged = true; };
    };
  };
  systemd.network.netdevs."br0" = {
    enable = true;
    netdevConfig = {
      Name = "br0";
      Kind = "bridge";
    };
  };
}
