{ config, lib, pkgs, ... }:

{
  systemd.services.storage = {
    enable = true;
    description = "Grand Stores Mount";
    path = [ pkgs.lizardfs pkgs.kmod ];
    restartIfChanged = false; # don't want the filesystem falling out from under processes
    script = ''
      modprobe fuse
      mfsmount -o nodev,big_writes,allow_other,nonempty,mfsmaster=192.168.1.5 /mnt/storage
    '';
    wantedBy = [ "remote-fs.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "forking";
    };
  };
  systemd.tmpfiles.rules = [
    # Auto-make mount folders for filesystems that NixOS doesn't handle directly
    "d /mnt/storage 0755 root root -"
  ];
}
