{ config, lib, pkgs, ... }:

let
  xconfig = pkgs.writeText "nvidia-xconfig" ''
    Section "Files"
      ModulePath "${pkgs.linuxPackages.nvidia_x11.bin}/lib/xorg/modules/drivers"
      ModulePath "${pkgs.linuxPackages.nvidia_x11.bin}/lib/xorg/modules/extensions"
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
  services.transmission.enable = true;

  systemd.services.hack3bot = {
    enable = true;
    description = "Hack3 Bot";
    path = [ pkgs.yarn ];
    script = ''
      export BOT_TOKEN=$(cat /keys/hack3bot.token)
      cd /home/kevin/Projects/hack3bot
      yarn start
    '';
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  deployment.keys."hack3bot.token" = {
    permissions = "600"; # rclone must be able to modify
    destDir = "/keys";
    text = builtins.readFile ../../secrets/hack3bot.token;
  };

  nixpkgs.overlays = [ (import (builtins.fetchTarball https://github.com/nixos-rocm/nixos-rocm/archive/master.tar.gz)) ];
  services.xserver.videoDrivers = [ "nvidia" ];
  services.boinc = {
    enable = true;
    allowRemoteGuiRpc = true;
    extraEnvPackages = with pkgs; [
      ocl-icd linuxPackages.nvidia_x11 rocm-opencl-icd cudatoolkit
    ];
  };
  systemd.services.boinc.after = [ "display-manager.service" ];
  systemd.services.nvidia-fan = {
    enable = true;
    path = with pkgs; [ xorg.xorgserver linuxPackages.nvidia_x11.settings coreutils ];
    script = ''
      set -xeuo pipefail

      X :2 -novtswitch -logfile /dev/null -keeptty -sharevts vt2 -config ${xconfig} &
      sleep 5
      DISPLAY=:2 nvidia-settings -a '[gpu:0]/GPUFanControlState=1' -a '[fan:0]/GPUTargetFanSpeed=77'
      sleep infinity
    '';
    wantedBy = [ "multi-user.target" ];
  };

  hardware.opengl.extraPackages = [ pkgs.rocm-opencl-icd pkgs.linuxPackages.nvidia_x11.out ];
  environment.systemPackages = with pkgs; [ pkgs.rocm-opencl-runtime rocminfo pkgs.linuxPackages.nvidia_x11 ];
}
