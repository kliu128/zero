{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    helmfile kubectl kubernetes-helm k9s
  ];
}