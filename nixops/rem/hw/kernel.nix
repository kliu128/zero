{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "vm.min_free_kbytes" = 256000;
  };
}
