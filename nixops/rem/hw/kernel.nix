{ config, lib, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages;
  boot.kernel.sysctl."kernel.panic_on_oops" = 0;
}
