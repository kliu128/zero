{ config, lib, pkgs, ... }:

{
  services.tlp.enable = true; # For laptop
  powerManagement.powertop.enable = true;

  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
    options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
    options iwldvm force_cam=0
    options i915 enable_guc=3 enable_fbc=1
  '';
  boot.blacklistedKernelModules = [ "iTCO_wdt" ];
  boot.extraModulePackages = [ config.boot.kernelPackages.huawei-wmi ];
  systemd.tmpfiles.rules = [
    "w /sys/devices/platform/huawei-wmi/charge_thresholds - - - - 68 70"
  ];

  virtualisation.docker.enableOnBoot = false;

  services.undervolt = {
    enable = true;
    coreOffset = "-120";
  };
}
