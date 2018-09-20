{ config, pkgs, ... }:

{
  networking.networkmanager.dispatcherScripts = [ {
    source = ./remote-fs.sh;
    type = "basic";
  } ];
  fileSystems."/mnt/storage" = {
    fsType = "nfs";
    device = "${(import ../wireguard.nix).ips.rem}:/storage";
    options = [ "nofail" "noauto" "soft" "intr" ];
  };
  fileSystems."/mnt/home" = {
    fsType = "nfs";
    device = "${(import ../wireguard.nix).ips.rem}:/home";
    options = [ "nofail" "noauto" "soft" "intr" ];
  };
  systemd.services.unmount-nfs = {
    enable = true;
    serviceConfig = {
      ExecStop = "${pkgs.utillinux}/bin/umount -l -a -t nfs,nfs4";
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-manager.service" "wpa_supplicant.service" ];
    after = [ "network-manager.service" "wpa_supplicant.service" ];
  };
}
