{ config, lib, pkgs, ... }:

{
  networking.useNetworkd = true;
  networking.useDHCP = true;
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
        # Avoid networkd crash with https://github.com/systemd/systemd/issues/12452
        LinkLocalAddressing = "ipv4";
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

  # Fix failing network upon big NixOS updates
  systemd.services.systemd-networkd.restartIfChanged = false;
  systemd.services.systemd-resolved.restartIfChanged = false;

  # Disable IPv6, since it creates a "network changed" error in Chrome
  # see https://stackoverflow.com/questions/44678168/docker-and-chromium-neterr-network-changed
  boot.kernel.sysctl = {
    "net.ipv6.conf.all.disable_ipv6" = 1;
    "net.ipv6.conf.default.disable_ipv6" = 1;
  };
}
