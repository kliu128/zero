{ config, lib, pkgs, ... }:

let
  chunkserverDefaults = ''
    BIND_HOST = 192.168.1.5
    PERFORM_FSYNC = 0
    NICE_LEVEL = 5
    HDD_PUNCH_HOLES = 1
  '';
in {
  services.lizardfs.enable = true;
  services.lizardfs.cgiserv.enable = true;
  services.lizardfs.master.enable = true;

  # Bind only on local subnetwork
  services.lizardfs.master.config = ''
    MASTER_HOST = 192.168.1.5
    MATOML_LISTEN_HOST = 192.168.1.5
    MATOCS_LISTEN_HOST = 192.168.1.5
    MATOCL_LISTEN_HOST = 192.168.1.5
    MATOTS_LISTEN_HOST = 192.168.1.5
    AUTO_RECOVERY = 1
    REDUNDANCY_LEVEL = 0
    NICE_LEVEL = 5
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
  '';
  systemd.services.lizardfs-master = {
    wants = [
      "lizardfs-chunkserver-parity0.service"
      "lizardfs-chunkserver-wdblack1tb.service"
      "lizardfs-chunkserver-wdgreen15tb.service"
      "lizardfs-chunkserver-wdblue4tb.service"
      "lizardfs-chunkserver-toshiba4tb.service"
      "lizardfs-chunkserver-seagate8tb.service"
    ];
    after = [
      "lizardfs-chunkserver-parity0.service"
      "lizardfs-chunkserver-wdblack1tb.service"
      "lizardfs-chunkserver-wdgreen15tb.service"
      "lizardfs-chunkserver-wdblue4tb.service"
      "lizardfs-chunkserver-toshiba4tb.service"
      "lizardfs-chunkserver-seagate8tb.service"
    ];
    serviceConfig = {
      OOMScoreAdjust = -1000;
    };
  };
  services.lizardfs.chunkservers.masterHost = "192.168.1.5";
  services.lizardfs.chunkservers.servers = [
    {
      name = "parity0";
      config = chunkserverDefaults;
      storageDirectories = [ "/mnt/parity0/mfs" ];
      port = 9422;
    }
    {
      name = "wdblack1tb";
      config = chunkserverDefaults;
      storageDirectories = [ "/mnt/data1/mfs" ];
      port = 9423;
    }
    {
      name = "wdgreen15tb";
      storageDirectories = [ "/mnt/data0/mfs" ];
      port = 9426;
      config = chunkserverDefaults;
    }
    {
      name = "wdblue4tb";
      config = chunkserverDefaults;
      storageDirectories = [ "/mnt/data2/mfs" ];
      port = 9427;
    }
    {
      name = "toshiba4tb";
      config = chunkserverDefaults;
      storageDirectories = [ "/mnt/data3/mfs" ];
      port = 9428;
    }
    {
      name = "seagate8tb";
      storageDirectories = [ "/mnt/data4/mfs" ];
      port = 9429;
      config = chunkserverDefaults;
    }
  ];
  networking.firewall.allowedTCPPorts = [ 9421 9422 9423 9426 9427 9428 9429 ];
}
