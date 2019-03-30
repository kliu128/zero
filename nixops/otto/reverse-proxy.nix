{ config, lib, pkgs, ... }:

{
  services.sniproxy = {
    enable = true;
    config = ''
      error_log {
        # Log to the daemon syslog facility
        syslog daemon
      }
      # Global access log for all listeners
      access_log {
        # Log to the daemon syslog facility
        syslog daemon
      }

      listen 80 {
        proto http
      }
      listen 443 {
        proto tls
      }
      table {
        ^((.+\.)|())potatofrom\.space$ 10.99.0.1
      }
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
