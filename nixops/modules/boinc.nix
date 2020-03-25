{ config, lib, pkgs, ... }:

{
  services.boinc = {
    enable = true;
    allowRemoteGuiRpc = true;
  };
}
