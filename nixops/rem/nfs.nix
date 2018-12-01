{
  networking.firewall.allowedTCPPorts = [ 111 2049 4000 4001 4002 20048 ];
  networking.firewall.allowedUDPPorts = [ 111 2049 4000 4001 4002 20048 ];
  
  services.nfs.server = {
    enable = true;
    statdPort = 4000;
    lockdPort = 4001;
    mountdPort = 4002;
    exports = ''
      /srv/nfs 192.168.1.0/24(rw,fsid=0,sync,no_root_squash,crossmnt) ${(import ../wireguard.nix).subnet}(rw,fsid=0,sync,no_root_squash,crossmnt)
    '';
  };
}

