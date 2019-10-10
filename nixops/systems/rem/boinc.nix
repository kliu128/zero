{ config, lib, pkgs, ... }:

let
  xconfig = pkgs.writeText "nvidia-xconfig" ''
    Section "Files"
      ModulePath "${config.boot.kernelPackages.nvidia_x11.bin}/lib/xorg/modules/drivers"
      ModulePath "${config.boot.kernelPackages.nvidia_x11.bin}/lib/xorg/modules/extensions"
      ModulePath "${pkgs.xorg.xorgserver}/lib/xorg/modules"
      #ModulePath "${pkgs.xorg.xorgserver}/lib/xorg/modules/extensions"
      #ModulePath "${pkgs.xorg.xorgserver}/lib/xorg/modules/drivers"
    EndSection

    Section "ServerLayout"
            Identifier "dual"
            Screen 0 "Screen0"
    EndSection

    Section "Device"
        Identifier     "Device0"
        Driver         "nvidia"
        VendorName     "NVIDIA Corporation"
        BusID          "PCI:2:0:0"
        Option         "Coolbits"       "7"
        Option         "AllowEmptyInitialConfiguration"
    EndSection

    Section "Screen"
            Identifier     "Screen0"
            Device         "Device0"
    EndSection
  '';
in {
  services.xserver.videoDrivers = [ "nvidia" ];
  services.boinc = {
    enable = true;
    allowRemoteGuiRpc = true;
    extraEnvPackages = with pkgs; [
      ocl-icd config.boot.kernelPackages.nvidia_x11 cudatoolkit virtualbox
    ];
  };
  systemd.services.boinc.after = [ "display-manager.service" ];
  systemd.services.boinc.serviceConfig = {
    CPUSchedulingPolicy = "idle";
  };
  systemd.services.nvidia-fan = {
    enable = false;
    path = with pkgs; [ xorg.xorgserver config.boot.kernelPackages.nvidia_x11.settings coreutils ];
    script = ''
      set -xeuo pipefail

      X :2 -novtswitch -logfile /dev/null -keeptty -sharevts vt2 -config ${xconfig} &
      sleep 5
      DISPLAY=:2 nvidia-settings -a '[gpu:0]/GPUFanControlState=1' -a '[fan:0]/GPUTargetFanSpeed=77'
      sleep infinity
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # virtualisation.virtualbox.host = {
  #   enable = true;
  #   enableExtensionPack = true;
  # };

  hardware.opengl.extraPackages = with pkgs; [
    config.boot.kernelPackages.nvidia_x11.out
  ];
  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.nvidia_x11 
  ];
}
