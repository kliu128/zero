{ config, lib, pkgs, ... }:

{
  systemd.services.whatsapp-avd = {
    enable = true;
    path = [ pkgs.steam-run ];
    script = ''
      steam-run /home/kevin/Android/Sdk/emulator/emulator -avd WhatsApp -no-window -no-audio -memory 512
    '';
    restartIfChanged = false;
    serviceConfig = {
      User = "kevin";
      Group = "users";
      Nice = 19;
      CPUAffinity = "0";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
