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
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  home-manager.users.kevin.systemd.user.services.pulseaudio-mono = {
    Unit = {
      Description = "Pulseaudio Mono Daemon";
      Requires = "pulseaudio.service";
      After = "pulseaudio.service";
    };

    Service = {
      ExecStart = "${pkgs.python3.withPackages(pkgs: [ pkgs.dbus-python pkgs.pygobject3 ])}/bin/python3 ${./pulseaudio-mono.py}";
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}