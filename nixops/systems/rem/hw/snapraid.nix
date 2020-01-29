{ config, lib, pkgs, ... }:

{
  environment.etc."snapraid.conf".text = ''
    disk d0 /mnt/data0/Kevin
    disk d1 /mnt/data1/Kevin
    disk d2 /mnt/data2/Kevin
    disk d3 /mnt/data3/Kevin
    disk d5 /mnt/wdgreen1tb/Kevin
    parity /mnt/parity0/SnapRAID.parity
    content /mnt/data0/SnapRAID.content
    content /mnt/data1/SnapRAID.content
    content /mnt/data2/SnapRAID.content
    content /mnt/data3/SnapRAID.content
    content /mnt/wdgreen1tb/SnapRAID.content
    exclude /Incoming/
  '';
  environment.systemPackages = with pkgs; [ snapraid ];

  systemd.services.snapraid = {
    description = "SnapRAID sync and scrub";
    path = with pkgs; [ snapraid ];
    serviceConfig = {
      Nice = 19;
      IOSchedulingClass = "idle";
    };
    script = ''
      set -xeuo pipefail

      snapraid touch
      snapraid sync
      snapraid scrub
    '';
    startAt = "*-*-* 05:00:00";
  };
}
