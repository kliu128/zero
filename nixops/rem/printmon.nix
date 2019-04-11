{ config, lib, pkgs, ... }:

{
  systemd.services.printmon = {
    enable = true;
    description = "Printmon API Server";
    path = with pkgs; [ nix ];
    script = ''
      cd /home/kevin/Projects/printmon
      nix-shell -I nixpkgs=/etc/nixos/nixpkgs --run "cd packages/printmon-server; yarn start"
    '';
    serviceConfig = {
      User = "kevin";
      Group = "users";
    };
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  networking.firewall.allowedTCPPorts = [ 4005 ];
}