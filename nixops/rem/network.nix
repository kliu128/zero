{ config, lib, pkgs, ... }:

{
  networking.useNetworkd = true;
  networking.useDHCP = true;
  systemd.network.enable = true;
  services.resolved.dnssec = "false";
  systemd.network.networks = {
    "40-eth0" = {
      matchConfig = { Name = "eth0"; };
      DHCP = "yes";
    };
    "99-main" = {
      matchConfig = { Name = "*"; };
      linkConfig = { Unmanaged = true; };
    };
  };

  # Fix failing network upon big NixOS updates
  systemd.services.systemd-networkd.restartIfChanged = false;
  systemd.services.systemd-resolved.restartIfChanged = false;
}
