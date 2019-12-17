{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_5_3;
}
