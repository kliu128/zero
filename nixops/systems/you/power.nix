{ config, lib, pkgs, ... }:

{
  services.tlp.enable = true; # For laptop
  services.tlp.extraConfig = ''
    CPU_BOOST_ON_AC=1
    CPU_BOOST_ON_BAT=0
  '';
  powerManagement.powertop.enable = true;

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
  '';
  boot.kernelParams = [ "i915.enable_psr=0" ];
  boot.blacklistedKernelModules = [ "iTCO_wdt" ];
  systemd.tmpfiles.rules = [
    "w /sys/devices/platform/huawei-wmi/charge_thresholds - - - - 83 85"
  ];

  virtualisation.docker.enableOnBoot = false;
}
