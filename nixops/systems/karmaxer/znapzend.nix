{ config, lib, pkgs, ... }:

{
  services.znapzend = {
    enable = true;
    pure = true;
    zetup = {
      vms = {
        dataset = "vms/vms";
        plan = 	"1h=>10min,1d=>1h,1w=>1d,1m=>1w,1y=>1m";
      };
    };
  };
}