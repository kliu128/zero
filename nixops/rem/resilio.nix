{ config, lib, pkgs, ... }:

{
  services.resilio = {
    enable = true;
    enableWebUI = true;
  };
}