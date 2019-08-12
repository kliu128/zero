{ config, lib, pkgs, ... }:

{
  services.tlp.enable = true; # For laptop
  powerManagement.powertop.enable = true;

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
    options iwldvm force_cam=0
  '';
  boot.extraModulePackages = [ config.boot.kernelPackages.huawei-wmi ];
  systemd.tmpfiles.rules = [
    "w /sys/devices/platform/huawei-wmi/charge_thresholds - - - - 60 70"
  ];

  boot.kernelParams = [ "i915.enable_psr=0" ];

  virtualisation.docker.enableOnBoot = false;

  services.undervolt = {
    enable = true;
    coreOffset = "-120";
  };
}
