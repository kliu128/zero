{ config, lib, pkgs, ... }:

{
  systemd.services.printmon = {
    enable = false;
    description = "Printmon API Server";
    path = with pkgs; [ yarn nodejs-10_x ];
    script = ''
      cd /home/kevin/Projects/printmon/server
      PORT=4005 yarn start
    '';
    serviceConfig = {
      User = "kevin";
      Group = "users";
    };
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}