{ config, pkgs, lib, ... }:

{
  # Fixes "incomplete report" spam in dmesg
  # See https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1784152
  # Experienced on Linux 4.19-4.20 as of 2019-01-11
  # Note: this fix only works on Linux 4.14 (2019-01-21)
  systemd.services.rmmod-i2c-hid-before-sleep = {
    description = "Unload I2C touchscreen driver before sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kmod}/bin/rmmod i2c-hid";
    };
    before = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
  };

  systemd.services.modprobe-i2c-hid-after-sleep = {
    description = "Load I2C touchscreen driver after sleep";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.kmod}/bin/modprobe i2c-hid";
    };
    after = [ "suspend.target" ];
    wantedBy = [ "suspend.target" ];
  };
}
