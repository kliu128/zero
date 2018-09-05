{ config, pkgs, ... }:

{
  systemd.services.storage = {
    enable = true;
    description = "Grand Stores Mount";
    path = [ pkgs.lizardfs ];
    restartIfChanged = false; # don't want the filesystem falling out from under processes
    script = ''
      mfsmount -o nodev,noatime,mfsdelayedinit,big_writes,allow_other,nonempty,mfsmaster=10.100.0.1 /mnt/storage
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
  fileSystems."/mnt/home" = {
    fsType = "nfs";
    device = "${(import ../wireguard.nix).ips.rem}:/home";
    options = [ "x-systemd.automount" "noauto" "soft" "intr" ];
  };
}
