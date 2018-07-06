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
    (import ../ssh-keys.nix).kevin-rem
    (import ../ssh-keys.nix).kevin-emilia
    (import ../ssh-keys.nix).kevin-xt1575
  ];
  users.extraUsers.root.openssh.authorizedKeys.keys = [
    # For NixOps, use rem's key
    (import ../ssh-keys.nix).kevin-rem
  ];
  networking.firewall.allowedTCPPorts = [ 843 ];
}