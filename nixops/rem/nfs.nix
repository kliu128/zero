{
  networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
  
  fileSystems."/srv/nfs/zoneminder" = {
    device = "/mnt/data3/Kevin/Computing/Data/ZoneMinder";
    options = [ "bind" ];
  };
  fileSystems."/srv/nfs/home" = {
    device = "/home/kevin";
    options = [ "bind" ];
  };
  fileSystems."/srv/nfs/storage" = {
    device = "/mnt/storage";
    options = [ "bind" "x-systemd.after=storage.service" ];
  };
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    exports = ''
      /srv/nfs 192.168.1.0/24(rw,fsid=0,async,no_root_squash,crossmnt) ${(import ../wireguard.nix).subnet}(rw,fsid=0,async,no_root_squash,crossmnt)

      /srv/nfs/zoneminder 192.168.1.0/24(rw,async,nohide,insecure,no_root_squash)

      /srv/nfs/home ${(import ../wireguard.nix).subnet}(rw,async,nohide,insecure,no_root_squash)
      /srv/nfs/storage 192.168.1.0/24(rw,async,fsid=107,nohide,insecure,no_root_squash) ${(import ../wireguard.nix).subnet}(rw,async,fsid=107,nohide,insecure,no_root_squash)
    '';
  };
}

