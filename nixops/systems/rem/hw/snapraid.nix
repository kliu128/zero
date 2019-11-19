{ config, lib, pkgs, ... }:

{
  environment.etc."snapraid.conf".text = ''
    disk d0 /mnt/data0/Kevin
    disk d1 /mnt/data1/Kevin
    disk d2 /mnt/data2/Kevin
    disk d3 /mnt/data3/Kevin
    disk d4 /mnt/data4/Kevin
    disk d5 /mnt/wdgreen1tb
    parity /mnt/parity0/SnapRAID.parity
    content /mnt/data0/SnapRAID.content
    content /mnt/data1/SnapRAID.content
    content /mnt/data2/SnapRAID.content
    content /mnt/data3/SnapRAID.content
    exclude /Incoming/
  '';
  environment.systemPackages = with pkgs; [ snapraid ];
}
