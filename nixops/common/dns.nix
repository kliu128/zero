{ config, lib, pkgs, ... }:

{
  services.resolved.enable = lib.mkForce false;
  networking.nameservers = [ "::1" ];

  services.unbound = {
    enable = true;
    extraConfig = ''
        tls-cert-bundle: /etc/ssl/certs/ca-certificates.crt
      
      forward-zone:
        name: "."
        forward-tls-upstream: yes
        # Cloudflare DNS
        forward-addr: 1.1.1.1@853#cloudflare-dns.com
        forward-addr: 1.0.0.1@853#cloudflare-dns.com
        forward-addr: 2606:4700:4700::1111@853#cloudflare-dns.com
        forward-addr: 2606:4700:4700::1001@853#cloudflare-dns.com
    '';
  };
}