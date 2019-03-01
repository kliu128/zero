{ config, lib, pkgs, ... }:

{
  services.kubernetes.roles = [ "node" ];
}