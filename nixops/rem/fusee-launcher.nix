{ config, lib, pkgs, ... }:

{
  environment.etc."fusee-payload.bin" = {
    mode = "444";
    source = ../hekate_ctcaer_3.0.bin;
  };
  systemd.services.fusee-launcher = {
    enable = true;
    path = [ pkgs.fusee-launcher ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      while true; do
        fusee-launcher -w /etc/fusee-payload.bin || true
      done
    '';
    serviceConfig.CPUQuota = "5%";
    serviceConfig.CPUSchedulingPolicy = "idle";
  };
}