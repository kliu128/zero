{ config, lib, pkgs, ... }:

{
  systemd.services.storage = {
    enable = true;
    description = "Grand Stores Mount";
    path = [ pkgs.lizardfs pkgs.kmod ];
    restartIfChanged = false; # don't want the filesystem falling out from under processes
    script = ''
      modprobe fuse
      mfsmount -o nodev,noatime,mfsdelayedinit,big_writes,allow_other,nonempty,mfsmaster=192.168.1.5 /mnt/storage
    '';
    wantedBy = [ "local-fs.target" ];
    serviceConfig = {
      Type = "forking";
    };
    unitConfig = {
      # Implicitly adds dependency on basic.target otherwise, which creates
      # an ordering cycle on boot
      DefaultDependencies = false;
      # Normally would be added by DefaultDependencies=
      Conflicts = [ "shutdown.target" ];
      Before = [ "shutdown.target" ];
    };
  };
  systemd.tmpfiles.rules = [
    # Auto-make mount folders for filesystems that NixOS doesn't handle directly
    "d /mnt/storage 0755 root root -"
  ];
}
