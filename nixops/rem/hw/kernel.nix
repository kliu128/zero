{ config, lib, pkgs, ... }:

{
  boot.kernelParams = [  ];
  boot.kernelPackages = pkgs.linuxPackages_4_19;
}
