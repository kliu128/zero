{ config, lib, pkgs, ... }:

{
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    ports = [ 843 ];
    forwardX11 = true;
  };
  programs.mosh.enable = true;
  services.fail2ban = {
    enable = true;
    jails.ssh-iptables = "enabled = true";
  };
  users.extraUsers.kevin.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQDtQm7AWGKLgSK2TE1nIus65ZD+jQl6TVGHQaOfFn/ kevin@rem"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINvRm/l9jaQ3fN5ZQvmZCfhKGHgtizonT9BRSKFbbgro kevin@emilia"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGBlgyWrDlIJ5RWigaWGOmjVWBpPqqJ/cL58yJblfm33 kevin@xt1575"
  ];
  users.extraUsers.root.openssh.authorizedKeys.keys = [
    # For NixOps
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBQDtQm7AWGKLgSK2TE1nIus65ZD+jQl6TVGHQaOfFn/ kevin@rem"
  ];
  networking.firewall.allowedTCPPorts = [ 843 ];
}