{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ chromium brave ];
}
