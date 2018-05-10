{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [ "netconsole" ];
  boot.extraModprobeConfig = ''
    options netconsole netconsole=6666@192.168.1.175/enp2s0,6666@192.168.1.5/
  '';
}