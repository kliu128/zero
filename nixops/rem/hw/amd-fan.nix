{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
   ACTION=="add|change", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", ATTR{pwm1_enable}="1"
   ACTION=="add|change", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", ATTR{pwm1}="220"
  '';
}
