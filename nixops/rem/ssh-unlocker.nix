{ config, lib, pkgs, ... }:

{
  systemd.services.ssh-unlocker = {
    description = "Unlock LUKS of other servers via SSH";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.python3.withPackages(pkgs: [ pkgs.pexpect ])}/bin/python3 ${./ssh-unlocker.py}";
    };
    path = with pkgs; [ openssh ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    startAt = "minutely";
  };
  deployment.keys."unlocker_id_rsa" = {
    permissions = "400";
    destDir = "/keys/ssh-unlocker";
    text = builtins.readFile ../secrets/ssh-unlocker/unlocker_id_rsa;
  };
  deployment.keys."hosts.json" = {
    permissions = "400";
    destDir = "/keys/ssh-unlocker";
    text = builtins.readFile ../secrets/ssh-unlocker/hosts.json;
  };
  deployment.keys."known_hosts" = {
    permissions = "400";
    destDir = "/keys/ssh-unlocker";
    text = builtins.readFile ../secrets/ssh-unlocker/known_hosts;
  };
}