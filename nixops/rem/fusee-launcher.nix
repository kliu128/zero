{ config, lib, pkgs, ... }:

{
  systemd.services.fusee-launcher = {
    enable = true;
    path = [ pkgs.fusee-launcher ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      while true; do
        fusee-launcher -w ${../hekate_ctcaer_4.2.bin} || true
      done
    '';
    serviceConfig.Nice = 19;
    serviceConfig.CPUQuota = "2%";
  };
}
