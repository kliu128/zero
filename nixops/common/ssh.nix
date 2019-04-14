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
    (import ../ssh-keys.nix).yubikey
    (import ../ssh-keys.nix).yubikey-backup
  ];
  users.extraUsers.root.openssh.authorizedKeys.keys = [
    # For NixOps, deploy using yubikey
    (import ../ssh-keys.nix).yubikey
    (import ../ssh-keys.nix).yubikey-backup
  ];
  networking.firewall.allowedTCPPorts = [ 843 ];

  environment.systemPackages = [ pkgs.htop ];
}