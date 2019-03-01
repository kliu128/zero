{ config, pkgs, lib, ... }:

{
  services.lizardfs.enable = true;
  services.lizardfs.metalogger = {
    masterHost = "10.99.0.1";
    enable = true;
  };
  services.lizardfs.chunkservers.masterHost = "10.99.0.1";
  services.lizardfs.chunkservers.servers = [
    {
      name = "localdisk";
      port = 9422;
      storageDirectories = ["/var/lib/lizardfs-data"];
      config = ''
        BIND_HOST = 10.99.0.2
        PERFORM_FSYNC = 0
        HDD_PUNCH_HOLES = 1
        HDD_LEAVE_SPACE_DEFAULT = 50GiB
      '';
    }
    {
      name = "250gb-netbook-hdd";
      port = 9423;
      storageDirectories = ["/mnt/250gb-netbook-hdd/mfs"];
      config = ''
        BIND_HOST = 10.99.0.2
        PERFORM_FSYNC = 0
        HDD_PUNCH_HOLES = 1
      '';
    }
    {
      name = "150gb-dell-hdd";
      port = 9424;
      storageDirectories = ["/mnt/150gb-dell-hdd/mfs"];
      config = ''
        BIND_HOST = 10.99.0.2
        PERFORM_FSYNC = 0
        HDD_PUNCH_HOLES = 1
      '';
    }
  ];
  networking.firewall.allowedTCPPorts = [ 9422 9423 9424 ];
}
