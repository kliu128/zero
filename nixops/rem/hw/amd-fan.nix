{ config, lib, pkgs, ... }:

{
  systemd.services.amdgpu-fan = {
    enable = true;
    path = with pkgs; [ amdgpu-fan ];
    script = ''
      amdgpu-fan
    '';
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Restart = "always";
  };
  environment.etc."amdgpu-fan.yml".text = ''
    # /etc/amdgpu-fan.yml
    # eg:

    speed_matrix:  # -[temp(*C), speed(0-100%)]
    - [0, 0]
    - [45, 30]
    - [60, 60]
    - [65, 75]
    - [70, 95]
    - [80, 100]

    # optional
    # cards:  # can be any card returned from 
    #         # ls /sys/class/drm | grep "^card[[:digit:]]$"
    # - card0
  '';
}
