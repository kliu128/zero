{ config, lib, pkgs, ... }:

{
  services.tlp.enable = true; # For laptop
  services.tlp.extraConfig = ''
    CPU_BOOST_ON_BAT=1
  '';
  powerManagement.powertop.enable = true;

  boot.extraModulePackages = [ pkgs.linuxPackages_latest.huawei-wmi ];
  systemd.tmpfiles.rules = [
    "w /sys/devices/platform/huawei-wmi/charge_thresholds - - - - 40 70"
  ];
}
