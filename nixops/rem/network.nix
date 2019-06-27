{ config, lib, pkgs, ... }:

{
  networking.useNetworkd = true;
  networking.useDHCP = true;
  systemd.network.networks."40-br0".linkConfig.MACAddress = "74:d4:35:e2:52:9b";
  systemd.network.networks."40-br0".networkConfig.DHCP = lib.mkForce "ipv4";
  systemd.network.enable = true;
  services.resolved.dnssec = "false";
  systemd.network.networks."99-main".enable = false;

  # Fix failing network upon big NixOS updates
  systemd.services.systemd-networkd.restartIfChanged = false;
  systemd.services.systemd-resolved.restartIfChanged = false;
}
