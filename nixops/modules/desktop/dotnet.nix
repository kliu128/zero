{ config, lib, pkgs, ... }:

{
  # opt out of dotnet core telemetry thank you
  environment.variables.DOTNET_CLI_TELEMETRY_OPTOUT = "1";

  environment.systemPackages = [ pkgs.dotnet-sdk_3 ];
}