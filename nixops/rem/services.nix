{ config, lib, pkgs, ... }:

{
  systemd.services.matrix-discord = {
    enable = true;
    path = with pkgs; [ nix ];
    script = ''
      cd /home/kevin/Projects/matrix-appservice-discord
      nix-shell -I nixpkgs=/etc/nixos/nixpkgs -p sqlite gcc python2 nodePackages.npm nodejs-8_x --run "npm install && npm start"
    '';
    serviceConfig = {
      User = "kevin";
      Group = "users";
    };
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 9005 ];
}