{ config, pkgs, ... }:

{
  fileSystems."/mnt/storage" = {
    fsType = "nfs";
    device = "${(import ../wireguard.nix).ips.rem}:/storage";
    options = [ "x-systemd.automount" "noauto" "soft" "intr" ];
  };
  fileSystems."/mnt/home" = {
    fsType = "nfs";
    device = "${(import ../wireguard.nix).ips.rem}:/home";
    options = [ "x-systemd.automount" "noauto" "soft" "intr" ];
  };
}
