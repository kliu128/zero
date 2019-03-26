{ config, lib, pkgs, ... }:

{
  home-manager.users.kevin.systemd.user.services = {
    anbox-session-manager = {
      Unit = {
        Description = "Anbox Session Manager";
        After = "graphical-session-pre.target";
        PartOf = "graphical-session.target";
      };
      Service = {
        ExecStart = "${pkgs.anbox}/bin/anbox session-manager";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
    whatsapp = {
      Unit = {
        Description = "Anbox: WhatsApp intent";
      };
      Service = {
        After = "anbox-session-manager.service";
        Wants = "anbox-session-manager.service";
        Type = "oneshot";
        ExecStart = "${pkgs.coreutils}/bin/sleep 1";
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
