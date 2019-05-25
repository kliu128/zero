{ config, lib, pkgs, ... }:

{
  systemd.services.matrix-discord = {
    enable = true;
    path = with pkgs; [ nix ];
    script = ''
      cd /home/kevin/Projects/matrix-appservice-discord
      nix-shell -I nixpkgs=/etc/nixos/nixpkgs -p sqlite gcc python2 nodePackages.npm nodejs-8_x --run "npm start"
    '';
    serviceConfig = {
      User = "kevin";
      Group = "users";
    };
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 8080 9005 ];

  services.calibre-server = {
    enable = false;
    libraryDir = "/mnt/storage/Kevin/Literature/eBooks --userdb /var/lib/calibre-users.sqlite --enable-auth";
  };
}