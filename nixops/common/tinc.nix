{ config, lib, pkgs, ... }:

{
  # configure tinc service
  # ----------------------
  services.tinc.networks."omnimesh"= {
    interfaceType = "tap";
    extraConfig = ''
      Mode = switch
      ConnectTo = rem
    '';
    hosts = {
      rem = ''
        Address = 192.168.1.5
        ${builtins.readFile ../secrets/tinc/rem/ed25519_key.pub}
        ${builtins.readFile ../secrets/tinc/rem/rsa_key.pub}
        '';
      otto = ''
        Address = 192.168.1.11
        ${builtins.readFile ../secrets/tinc/otto/ed25519_key.pub}
        ${builtins.readFile ../secrets/tinc/otto/rsa_key.pub}
      '';
    };
  };
  networking.firewall.allowedTCPPorts = [ 655 ];
  networking.firewall.allowedUDPPorts = [ 655 ];
}