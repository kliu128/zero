{ config, lib, pkgs, ... }:

{
  services.znapzend = {
    enable = true;
    pure = true;
    zetup = {
      vms = {
        mbuffer.enable = true;
        dataset = "vms/vms";
        plan = 	"1h=>10min,1d=>1h,1w=>1d,1m=>1w,1y=>1m";
        destinations.rem = {
          dataset = "wd-my-book-12tb/backups/karmaxer-vms";
          host = "znapzend-rem";
        };
      };
    };
  };
  programs.ssh.extraConfig = ''
    Host znapzend-rem
      HostName 192.168.1.5
      User znapzend
      Port 843
      IdentityFile /root/.ssh/id_rsa
  '';
  deployment.keys."id_rsa" = {
    permissions = "400";
    destDir = "/root/.ssh";
    text = builtins.readFile ../../secrets/karmaxer-znapzend-ssh-key;
  };
}
