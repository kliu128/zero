{
  networking.firewall.allowedTCPPorts = [ 111 2049 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 ];
  
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
    device = "/mnt/storage/Kevin/Computing/Data/ZoneMinder";
    options = [ "bind" "x-systemd.after=storage.service" ];
  };
  services.nfs.server = {
    enable = true;
    exports = ''
      /srv/nfs *.lan(rw,fsid=0,async,no_root_squash,crossmnt)
      /srv/nfs/books *.lan(rw,fsid=100,async,insecure,nohide,no_root_squash)
      /srv/nfs/incoming *.lan(rw,fsid=102,async,nohide,insecure,no_root_squash)
      /srv/nfs/movies *.lan(rw,fsid=103,async,nohide,insecure,no_root_squash)
      /srv/nfs/mineos-backups *.lan(rw,fsid=104,async,nohide,insecure,no_root_squash)
      /srv/nfs/tv-shows *.lan(rw,fsid=105,async,nohide,insecure,no_root_squash)
      /srv/nfs/zoneminder *.lan(rw,fsid=106,async,nohide,insecure,no_root_squash)
    '';
  };
}

