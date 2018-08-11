{ config, lib, pkgs, ... }:

{
  services.ipfs.enable = true;
  services.ipfs.apiAddress = "/ip4/127.0.0.1/tcp/5001";
  services.ipfs.gatewayAddress = "/ip4/127.0.0.1/tcp/8085";
  services.ipfs.swarmAddress = [ "/ip4/0.0.0.0/tcp/4005" ];
}