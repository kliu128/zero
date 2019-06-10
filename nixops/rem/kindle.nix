{ config, lib, pkgs, ... }:

{
  networking.usePredictableInterfaceNames = false;

  networking.interfaces.usb0.ipv4.addresses = [ { address = "192.168.15.201"; prefixLength = 24; } ];
  systemd.services.kindle-status = {
    enable = true;
    path = [ pkgs.sshpass pkgs.openssh ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      SSHPASS="$(cat /keys/kindle-root-password.txt)" sshpass -e ssh -o StrictHostKeyChecking=no root@192.168.15.244 "DISPLAY=:0.0 /mnt/us/extensions/kterm/bin/kterm -c 1 -k 0 -s 6 -e 'ssh kindle@192.168.15.201 -p 843 -t -- tail -f | htop --delay=100'"
    '';
    serviceConfig.Restart = "always";
  };
  deployment.keys."kindle-root-password.txt" = {
    permissions = "400";
    destDir = "/keys";
    text = builtins.readFile ../secrets/kindle-root-password.txt;
  };
  users.users.kindle = {
    home = "/home/kindle";
    shell = pkgs.bash;
    description = "Kindle Status User";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuhNYOw//qjZTsQT99TavXaLAJLHmaDXV4YZowNWSMS root@kindle"
    ];
    # Able to see all processes (for htop view)
    extraGroups = [ "proc" ];
  };
  home-manager.users.kindle.home.packages = [ pkgs.htop ];
}