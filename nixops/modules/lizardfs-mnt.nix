{ config, lib, pkgs, ... }:

{
  systemd.services.storage = {
    enable = true;
    description = "Grand Stores LizardFS Mount";
    path = [ pkgs.lizardfs pkgs.kmod ];
    restartIfChanged = false; # don't want the filesystem falling out from under processes
    script = ''
      modprobe fuse
      mfsmount -o nodev,big_writes,allow_other,nonempty,mfsmaster=10.99.0.1,mfsnice=0 /mnt/storage
    '';
    wantedBy = [ "remote-fs.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    unitConfig = {
      StartLimitIntervalSec = 0; # Disable start interval bursting
    };
    serviceConfig = {
      Type = "forking";
      Restart = "on-failure";
      RestartSec = "5";
      Nice = 0;
      MemoryHigh = "1G";
      ExecStartPre = "-${pkgs.utillinux}/bin/umount -l /mnt/storage";
    };
  };
  systemd.tmpfiles.rules = [
    # Auto-make mount folders for filesystems that NixOS doesn't handle directly
    "d /mnt/storage 0755 root root -"
  ];
}
