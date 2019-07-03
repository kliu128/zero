{ config, lib, pkgs, ... }:

{
  # Audio
  hardware.pulseaudio = {
    enable = true;
    extraConfig = ''
      load-module module-dbus-protocol
    '';
    package = pkgs.pulseaudioFull;
    extraModules = [ pkgs.pulseaudio-modules-bt ];
  };
  hardware.bluetooth.enable = true;

  home-manager.users.kevin.systemd.user.services.pulseaudio-mono = {
    User = {
      Description = "Pulseaudio Mono Daemon";
      Requires = "pulseaudio.service";
      After = "pulseaudio.service";
    };

    Service = {
      Environment = "PATH=${lib.makeBinPath [ pkgs.python3Packages.dbus-python pkgs.python3Packages.pygobject3 ]}";
      ExecStart = "${pkgs.python3}/bin/ ${./pulseaudio-mono.py}";
    };
  };
}