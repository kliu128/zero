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
    text = builtins.readFile ../../secrets/ssh-unlocker/unlocker_id_rsa;
  };
  deployment.keys."hosts.json" = {
    permissions = "400";
    destDir = "/keys/ssh-unlocker";
    text = builtins.readFile ../../secrets/ssh-unlocker/hosts.json;
  };
  deployment.keys."known_hosts" = {
    permissions = "400";
    destDir = "/keys/ssh-unlocker";
    text = builtins.readFile ../../secrets/ssh-unlocker/known_hosts;
  };

  # iLO 2 scheduled power on/off
  systemd.services.ilo2-on = {
    path = [ pkgs.openssh ];
    script = ''
      ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /keys/rebooter rebooter@192.168.1.2 'power on'
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    startAt = "*-*-* 09:00:00";
  };
  systemd.services.ilo2-off = {
    path = [ pkgs.openssh ];
    script = ''
      ssh -o BatchMode=yes -o StrictHostKeyChecking=no -i /keys/rebooter rebooter@192.168.1.2 'power off'
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    startAt = [
      "Mon..Fri 15:00"
      "Sat,Sun 09:00"
    ];
  };


  # SSH key with permissions for user rebooter to reboot system
  deployment.keys."rebooter" = {
    permissions = "400";
    destDir = "/keys/";
    text = builtins.readFile ../../secrets/rebooter;
  };
}