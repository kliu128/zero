{ config, lib, pkgs, ... }:

let
  nixos_rocm = import (builtins.fetchTarball https://github.com/nixos-rocm/nixos-rocm/archive/master.tar.gz);
in {
  nixpkgs.overlays = [ nixos_rocm ];
  nixpkgs.config.rocmTargets = [ "gfx803" ];
  hardware.opengl.extraPackages = with pkgs; [ rocm-opencl-icd ];
  environment.systemPackages = with pkgs; [
    rocminfo rocm-opencl-runtime fahviewer fahcontrol
  ];
}
