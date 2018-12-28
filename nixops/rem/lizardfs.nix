{ config, lib, pkgs, ... }:

{
  services.lizardfs.enable = true;
  services.lizardfs.cgiserv.enable = true;
  services.lizardfs.master.enable = true;
  services.lizardfs.master.config = ''
    AUTO_RECOVERY = 1
  '';
  services.lizardfs.master.exports = ''
    192.168.1.0/24 / rw,maproot=0
    192.168.1.0/24 . rw,maproot=0
    10.100.0.0/24 / rw,maproot=0
  '';
  services.lizardfs.master.goals = ''
    6 ec_2_1 : $ec(2,1)
    7 ec_3_1 : $ec(3,1)
    8 ec_4_2 : $ec(4,2)
    9 highio_ec_2_1 : $ec(2,1) { highio highio highio }
  '';
  systemd.services.lizardfs-master = {
    serviceConfig = {
      OOMScoreAdjust = -1000;
    };
  };
  services.lizardfs.chunkservers.masterHost = "192.168.1.5";
  services.lizardfs.chunkservers.servers = [
    {
      name = "parity0";
      config = ''
        PERFORM_FSYNC = 0
      '';
      storageDirectories = [ "/mnt/parity0/mfs" ];
      port = 9422;
    }
    {
      name = "wdblack1tb";
      config = ''
        LABEL = highio
      '';
      storageDirectories = [ "/mnt/data1/mfs" ];
      port = 9423;
    }
    {
      name = "wdgreen15tb";
      storageDirectories = [ "/mnt/data0/mfs" ];
      port = 9426;
    }
    {
      name = "wdblue4tb";
      config = ''
        LABEL = highio
      '';
      storageDirectories = [ "/mnt/data2/mfs" ];
      port = 9427;
    }
    {
      name = "toshiba4tb";
      config = ''
        LABEL = highio
      '';
      storageDirectories = [ "/mnt/data3/mfs" ];
      port = 9428;
    }
    {
      name = "seagate8tb";
      storageDirectories = [ "/mnt/data4/mfs" ];
      port = 9429;
      config = ''
        PERFORM_FSYNC = 0
      '';
    }
  ];
  networking.firewall.allowedTCPPorts = [ 9421 9422 9423 9426 9427 9428 9429 ];
}
