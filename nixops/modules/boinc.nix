{ config, lib, pkgs, ... }:

{
  services.boinc.enable = true;
  services.boinc.allowRemoteGuiRpc = true;
}
