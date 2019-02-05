{ config, lib, pkgs, ... }:

{
  systemd.services.printmon = {
    description = "Printmon API Server";
    path = with pkgs; [ yarn ];
    script = ''
      cd /home/kevin/Projects/printmon
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