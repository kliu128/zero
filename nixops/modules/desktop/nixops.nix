{ config, lib, pkgs, ... }:

with import <nixpkgs> {};
with lib;

{
  environment.systemPackages = [ pkgs.nixopsUnstable ];
}