{ config, lib, pkgs, ... }:

{
  services.transmission.enable = true;

  systemd.services.hack3bot = {
    enable = true;
    description = "Hack3 Bot";
    path = [ pkgs.yarn ];
    script = ''
      export BOT_TOKEN=$(cat /keys/hack3bot.token)
      cd /home/kevin/Projects/hack3bot
      yarn start
    '';
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
  };
  deployment.keys."hack3bot.token" = {
    permissions = "600"; # rclone must be able to modify
    destDir = "/keys";
    text = builtins.readFile ../../secrets/hack3bot.token;
  };
  
  users.users.aneesh = {
    uid = 1007;
    hashedPassword = "$6$UzrMih86A0guoL$n8XvA2W3cHzb89Hpu..WYlgJ464U.11wkxf.5qspj1H90U2c4CKukTISquOfGSAOj0KNmJ5ieYdXeOKxyNBSQ0";
  };
  services.openssh.allowSFTP = false;
  services.openssh.extraConfig = ''
    Subsystem sftp internal-sftp
    Match User aneesh
      ChrootDirectory /srv/chroot
      AllowTCPForwarding no
      X11Forwarding no
      PasswordAuthentication yes
      PubkeyAuthentication no
      ForceCommand internal-sftp -d mc
  '';
  # Allow UNIX auth for password
  security.pam.services.sshd.unixAuth = lib.mkForce true;
  fileSystems."/srv/chroot/mc" = {
    device = "/srv/nfs/pvcs/default-mc-aneesh-vanilla-minecraft-datadir-pvc-e8ee47ba-c06c-11e9-a63b-74d435e2529b";
    options = [ "bind" ];
  };

  services.tor = {
    enable = true;
    extraConfig = ''
      ServerTransportListenAddr obfs4 0.0.0.0:32973
      ExtORPort auto
    '';
    relay = {
      enable = true;
      port = 32972;
      role = "bridge";
      nickname = "pot8torelayrem";
      contactInfo = "Kevin Liu <kevin@potatofrom.space>";
    };
  };
}
