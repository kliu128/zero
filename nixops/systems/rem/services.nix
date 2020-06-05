{ config, lib, pkgs, ... }:

{
  services.tor = {
    enable = true;
    relay = {
      enable = true;
      port = 32972;
      role = "relay";
      nickname = "potatorelay2";
      contactInfo = "kevin@kliu.io";
    };
    extraConfig = ''
      DirPort 32973
      ControlPort 9051
    '';
  };
  environment.systemPackages = with pkgs; [ nyx ];

  containers.trns = {
    autoStart = true;
    localAddress = "192.168.1.17/24";
    hostBridge = "br0";
    privateNetwork = true;
    bindMounts = {
      storage = {
        hostPath = "/mnt/storage/Kevin/Incoming";
        mountPoint = "/data";
        isReadOnly = false;
      };
    };
    config = {
      # Container networking boilerplate
      networking.useHostResolvConf = false;
      networking.nameservers = [ "1.1.1.1" ];
      networking.interfaces.eth0.ipv4.routes = [
        { address = "0.0.0.0"; prefixLength = 0; via = "192.168.1.1"; }
      ];

      # Configure transmission
      services.transmission = {
        enable = true;
        settings = {
          download-dir = "/data";
          rpc-authentication-required = true;
          rpc-whitelist-enabled = false;
          rpc-host-whitelist-enabled = false;
          rpc-username = "kevin";
          rpc-password = builtins.readFile ../../secrets/transmission-pwd.txt;
        };
      };
      systemd.services.transmission.unitConfig = {
        BindsTo = [ "wg-quick-warp.service" ];
        After = lib.mkForce [ "wg-quick-warp.service" ];
      };
      networking.firewall.allowedTCPPorts = [ 9091 ];

      # Cloudflare Warp setup
      networking.wg-quick.interfaces.warp = {
        privateKey = "cIZMwDyMm36+GZc6XW/huWaWS610WJUZJk9CAuxfbmE=";
        address = [
          "172.16.0.2/32"
          "fd01:5ca1:ab1e:85a4:f932:35aa:1584:9b2b/128"
        ];
        dns = [ "1.1.1.1" ];
        peers = [
          {
            publicKey = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
            allowedIPs = [ "0.0.0.0/0" "::/0" ];
            endpoint = "engage.cloudflareclient.com:2408";
          }
        ];
      };
    };
  };
}
