{ config, lib, pkgs, ... }:

{
  networking.usePredictableInterfaceNames = false;

  networking.interfaces.usb0.ipv4.addresses = [ { address = "192.168.15.201"; prefixLength = 24; } ];
  systemd.services.kindle-status = {
    enable = true;
    path = [ pkgs.telnet ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
    { sleep 1; echo "/mnt/us/extensions/kterm/bin/kterm -c 1 -k 0 -s 6 -e 'ssh kindle@192.168.15.201 -p 843 -t -- tail -f | htop --delay=100'"; sleep infinity; } | telnet 192.168.15.244
    '';
    serviceConfig.DynamicUser = true;
  };
  users.extraUsers.kindle = {
    shell = pkgs.bash;
    description = "Kindle Status User";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICuhNYOw//qjZTsQT99TavXaLAJLHmaDXV4YZowNWSMS root@kindle"
    ];
  };
}