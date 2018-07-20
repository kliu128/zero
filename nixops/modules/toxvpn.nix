{ config, lib, pkgs, ... }:

{
  services.toxvpn.enable = true;
  services.toxvpn.auto_add_peers = [
    "6a70bed58d7ae8ae35b8ffc83aca40ae4e593f9b29c9193bc50370f02565857fecc3b5010c7e"
  ];
}