{ config, pkgs, lib, ... }:

{
  services.lizardfs.enable = true;
  services.lizardfs.metalogger = {
    masterHost = "192.168.1.5";
    enable = true;
  };
  services.lizardfs.chunkservers.masterHost = "192.168.1.5";
  services.lizardfs.chunkservers.servers = [
    {
      name = "localdisk";
      port = 9422;
      storageDirectories = ["/var/lib/lizardfs-data"
      "/var/lib/lizardfs-data2/mfs"];
      config = ''
        HDD_LEAVE_SPACE_DEFAULT = 50GiB
      '';
    }
  ];
  networking.firewall.allowedTCPPorts = [ 9422 ];
}
