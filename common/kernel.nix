{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_testing_bcachefs;
}
