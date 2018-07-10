{ config, lib, pkgs, ... }:

{
  nixpkgs.config.packageOverrides = pkgs: rec {
    linux_4_14 = pkgs.linux_4_14.override {
      # Reduce latency, please
      extraConfig = ''
        PREEMPT y
        PREEMPT_RCU y
      '';
    };
  };
  boot.kernelPackages = pkgs.linuxPackages_4_14;
}
