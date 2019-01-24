{ config, lib, pkgs, ... }:

{
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=1
    options iwlwifi power_save=1 d0i3_disable=0 uapsd_disable=0
    options iwldvm force_cam=0
  '';
  boot.kernel.sysctl."kernel.nmi_watchdog" = 0;
  services.tlp.enable = true; # For laptop
  powerManagement.powertop.enable = true;
}
