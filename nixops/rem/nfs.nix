{
  networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
  
  fileSystems."/srv/nfs/home" = {
    device = "/home/kevin";
    options = [ "bind" ];
  };
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    exports = ''
      /srv/nfs 192.168.1.0/24(rw,fsid=0,async,no_root_squash,crossmnt) ${(import ../wireguard.nix).subnet}(rw,fsid=0,async,no_root_squash,crossmnt)

      /srv/nfs/home ${(import ../wireguard.nix).subnet}(rw,async,nohide,insecure,no_root_squash)
      /srv/nfs/storage ${(import ../wireguard.nix).subnet}(rw,async,fsid=1,no_root_squash)
    '';
  };
}

