{ config, lib, pkgs, ... }:

{
  fileSystems."/srv/nfs" = {
    device = "rem.lan:/";
    fsType = "nfs";
    options = [ "intr" "soft" "tcp" "_netdev" "x-systemd.automount" ];
  };
}
