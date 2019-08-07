{ config, lib, pkgs, ... }:

{
  # virtualisation.anbox.enable = true;
  # systemd.network.netdevs.anbox-dummy = {
  #   enable = true;
  #   netdevConfig.Name = "anbox-dummy";
  #   netdevConfig.Kind = "dummy";
  # }; 
  # systemd.network.networks.anbox-dummy = {
  #   enable = true;
  #   matchConfig.Name = "anbox-dummy";
  #   networkConfig = {
  #     Bridge = "anbox0";
  #     DHCP = "no";
  #   };
  # };
  # systemd.services.anbox-container-manager.unitConfig.PartOf = "anbox-session-manager.service";
  # systemd.services.anbox-session-manager = {
  #   enable = false;
  #   description = "Anbox: Android in a Box";
  #   serviceConfig = {
  #     User = "kevin";
  #     Group = "users";
  #     Type = "notify";
  #     NotifyAccess = "all";
  #   };
  #   path = with pkgs; [ xvfb_run anbox systemd coreutils ];
  #   # See https://github.com/anbox/anbox/issues/597 for XDG_RUNTIME_DIR
  #   script = ''
  #     export XDG_RUNTIME_DIR=/run/user/1000
  #     xvfb-run -s '-screen 0 1920x1080x24' -n 99 anbox session-manager \
  #       --single-window &
  #     ANBOX_PID=$!
  #     while ! anbox wait-ready; do sleep 0.5; done
  #     systemd-notify --ready --status="Anbox fully started." --pid=$ANBOX_PID
  #   '';
  #   after = [ "anbox-container-manager.service" ];
  #   wantedBy = [ "multi-user.target" ];
  # };
  # systemd.services.anbox-vnc = {
  #   enable = false;
  #   description = "Anbox X11VNC Server";
  #   path = with pkgs; [ x11vnc ];
  #   script = ''
  #     exec x11vnc -many -display :99 -localhost
  #   '';
  #   unitConfig.PartOf = "anbox-session-manager.service";
  #   after = [ "anbox-session-manager.service" ];
  #   wantedBy = [ "multi-user.target" ];
  # };
}
