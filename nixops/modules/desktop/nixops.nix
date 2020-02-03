{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.nixopsUnstable ];
}