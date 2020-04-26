{
  networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
  
  services.rpcbind.options = "-h 192.168.1.5";
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    hostName = "192.168.1.5"; # Don't bind on all interfaces
    exports = ''
      /srv/nfs 192.168.1.5(rw,fsid=0,sync,no_root_squash,crossmnt) 192.168.1.3(rw,fsid=0,sync,no_root_squash,crossmnt) 192.168.1.157(rw,fsid=0,sync,no_root_squash,crossmnt)
    '';
  };
  systemd.services.nfs-server.restartIfChanged = false;
  systemd.services.nfs-idmapd.restartIfChanged = false;
  systemd.services.nfs-mountd.restartIfChanged = false;
  systemd.services.rpc-statd.restartIfChanged = false;

  fileSystems."/srv/nfs/overflow" = {
    device = "wd-my-book-12tb/overflow";
    fsType = "zfs";
    options = [ "nofail" ];
  };
}

