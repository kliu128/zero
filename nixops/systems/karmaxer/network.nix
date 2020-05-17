{ config, lib, pkgs, ... }:

{
  networking.useNetworkd = true;
  networking.useDHCP = false; # not supported by systemd-networkd
  systemd.network.enable = true;
  services.resolved.dnssec = "false";
  systemd.network.networks = {
    "40-enp" = {
      matchConfig = { Name = "enp2s0f0"; };
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
        MACAddress = "78:e7:d1:7b:d4:b2";
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