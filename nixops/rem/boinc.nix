{ config, lib, pkgs, ... }:

let
  nixos-rocm = builtins.fetchTarball https://github.com/nixos-rocm/nixos-rocm/archive/master.tar.gz;
in {
  nixpkgs.overlays = [
    (import nixos-rocm)
  ];
  environment.systemPackages = with pkgs; [
    rocm-opencl-runtime
  ];
}
