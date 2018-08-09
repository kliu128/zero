{
  networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
  
  fileSystems."/srv/nfs/books" = {
    device = "/mnt/storage/Kevin/Literature/eBooks";
    options = [ "bind" "x-systemd.after=storage.service" ];
  };
  fileSystems."/srv/nfs/incoming" = {
    device = "/mnt/storage/Kevin/Incoming";
    options = [ "bind" "x-systemd.after=storage.service" ];
  };
  fileSystems."/srv/nfs/movies" = {
    device = "/mnt/storage/Kevin/Videos/Movies";
    options = [ "bind" "x-systemd.after=storage.service" ];
  };
  fileSystems."/srv/nfs/tv-shows" = {
    device = ''/mnt/storage/Kevin/Videos/TV\040Shows'';
    options = [ "bind" "x-systemd.after=storage.service" ];
  };
  fileSystems."/srv/nfs/mineos-backups" = {
    device = "/mnt/storage/Kevin/Backups/Minecraft/Current";
    options = [ "bind" "x-systemd.after=storage.service" ];
  };
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

      /srv/nfs/books 192.168.1.0/24(rw,fsid=100,async,insecure,nohide,no_root_squash)
      /srv/nfs/incoming 192.168.1.0/24(rw,fsid=102,async,nohide,insecure,no_root_squash)
      /srv/nfs/movies 192.168.1.0/24(rw,fsid=103,async,nohide,insecure,no_root_squash)
      /srv/nfs/mineos-backups 192.168.1.0/24(rw,fsid=104,async,nohide,insecure,no_root_squash)
      /srv/nfs/tv-shows 192.168.1.0/24(rw,fsid=105,async,nohide,insecure,no_root_squash)
      /srv/nfs/zoneminder 192.168.1.0/24(rw,fsid=106,async,nohide,insecure,no_root_squash)

      /srv/nfs/home ${(import ../wireguard.nix).subnet}(rw,async,nohide,insecure,no_root_squash)
      /srv/nfs/storage ${(import ../wireguard.nix).subnet}(rw,async,fsid=107,nohide,insecure,no_root_squash)
    '';
  };
}

