{ config, lib, pkgs, ... }:

{
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", ATTR{pwm1_enable}="0"
    ACTION=="add|change", SUBSYSTEM=="hwmon", ATTR{name}=="amdgpu", ATTR{pwm1}="220"
  '';
}
