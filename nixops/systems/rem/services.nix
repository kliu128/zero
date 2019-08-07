{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 2222 19000 19001 ];
  services.stunnel = {
    enable = false;
    servers.ssh = {
      accept = 2222;
      connect = 843;
      cert = ../../secrets/stunnel.pem;
    };
  };

  systemd.services.hack3bot = {
    enable = true;
    description = "Hack3 Bot";
    path = [ pkgs.yarn ];
    script = ''
      export BOT_TOKEN=$(cat /keys/hack3bot.token)
      cd /home/kevin/Projects/hack3bot
      yarn start
    '';
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  deployment.keys."hack3bot.token" = {
    permissions = "600"; # rclone must be able to modify
    destDir = "/keys";
    text = builtins.readFile ../../secrets/hack3bot.token;
  };
}