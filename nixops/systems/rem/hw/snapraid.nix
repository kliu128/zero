{ config, lib, pkgs, ... }:

{
  environment.etc."snapraid.conf".text = ''
    disk d1 /mnt/sda
    disk d2 /mnt/sdb
    disk d3 /mnt/sdc
    disk d4 /mnt/sdd/I_only_want_to_backup_this_folder
    parity /mnt/sde/SnapRAID.parity
    content /mnt/sda/SnapRAID.content
    content /mnt/sdb/SnapRAID.content
    content /mnt/sdc/SnapRAID.content
    content /var/snapraid/SnapRAID.content
    exclude /lost+found/
  '';
  environment.systemPackages = with pkgs; [ snapraid ];
}
