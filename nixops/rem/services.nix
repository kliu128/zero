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
  networking.firewall.allowedTCPPorts = [ 8080 9005 25567 ];

  services.calibre-server = {
    enable = false;
    libraryDir = "/mnt/storage/Kevin/Literature/eBooks --userdb /var/lib/calibre-users.sqlite --enable-auth";
  };

  services.minecraft-server = {
    enable = false;
    eula = true;
    declarative = true;
    openFirewall = true;
    package = pkgs.minecraft-server_1_13_2;
    jvmOpts = "-Xmx1G";
    serverProperties = {
      server-port = 25566;
      enable-command-block = true;
      allow-flight = true;
      motd = "NixOS Diversity 3";
      difficulty = 2;
    };
  };
  systemd.services.forever-stranded = {
    enable = true;
    path = [ pkgs.jdk pkgs.bash pkgs.wget pkgs.gawk pkgs.glibc pkgs.inetutils pkgs.which ];
    script = ''
      cd /var/lib/minecraft-forever-stranded
      bash ServerStart.sh
    '';
    wantedBy = [ "multi-user.target" ];
  };
}