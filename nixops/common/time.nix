{ config, lib, pkgs, ... }:

{
  # Don't use default systemd-timesyncd, use chronyd
  services.timesyncd.enable = false;
  services.chrony.enable = true;
}