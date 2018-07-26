{ config, lib, pkgs, ... }:

{
  services.boinc.enable = true;
  services.boinc.allowRemoteGuiRpc = true;
  system.activationScripts.boinc-config = {
    text = ''
      cd /var/lib/boinc
      ${pkgs.boinc}/bin/boinccmd --set_run_mode always
      ${pkgs.boinc}/bin/boinccmd --set_network_mode always
      ${pkgs.boinc}/bin/boinccmd --join_acct_mgr http://bam.boincstats.com/ Pneumaticat '${builtins.readFile ../secrets/boincstats-password.txt}'
    '';
    deps = [];
  };
}