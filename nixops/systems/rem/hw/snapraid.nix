{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.snapraid ];

  environment.etc."snapraid.conf".text = ''
    parity /mnt/parity0/snapraid.parity
    content /mnt/data0/snapraid.content
    content /mnt/data1/snapraid.content
    content /mnt/data2/snapraid.content
    content /mnt/data3/snapraid.content
    content /mnt/wdgreen1tb/snapraid.content

    autosave 1000

    data data0 /mnt/data0
    data data1 /mnt/data1
    data data2 /mnt/data2
    data data3 /mnt/data3
    data wdgreen1tb /mnt/wdgreen1tb

    exclude /Kevin/Incoming/
    exclude /Kevin/Computing/StorjData/storage/*.db-wal
    exclude /Kevin/Computing/StorjData/storage/*.db-shm
  '';

  systemd.services.snapraid = {
    enable = true;
    description = "SnapRAID sync";
    path = [ pkgs.snapraid ];
    script = ''
      snapraid --force-zero sync
      snapraid scrub
    '';
    startAt = "*-*-* 04:00:00";
  };
}
