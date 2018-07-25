{ config, pkgs, ... }:

{
  fileSystems."/mnt/storage" = {
    fsType = "nfs";
    device = "${(import ../wireguard.nix).ips.rem}:/srv/nfs/storage";
    options = [ "vers=3" "x-systemd.automount" "noauto" "soft" "intr" ];
  };
  fileSystems."/mnt/home" = {
    fsType = "nfs";
    device = "${(import ../wireguard.nix).ips.rem}:/srv/nfs/home";
    options = [ "vers=3" "x-systemd.automount" "noauto" "soft" "intr" ];
  };
}
