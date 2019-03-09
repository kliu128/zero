{ config, lib, pkgs, ... }:

{
  boot.extraModprobeConfig = ''
    options netconsole netconsole=6666@192.168.1.5/br0,6666@192.168.1.11/
  '';

  systemd.services.netconsole = {
    enable = false;
    description = "Initialize netconsole logging to otto";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.kmod}/bin/modprobe netconsole";
      ExecStop = "${pkgs.kmod}/bin/rmmod netconsole";
    };
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
  };
}
