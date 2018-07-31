{ config, lib, pkgs, ... }:

{
  networking.nameservers = [ "::1" ];
  services.unbound = {
    enable = true;
    interfaces = [ "127.0.0.1" "::1" ];
    extraConfig = ''
        local-zone: "netflix.com" typetransparent
        local-data: "netflix.com IN AAAA ::2"

        local-zone: "netflix.net" typetransparent
        local-data: "netflix.net IN AAAA ::2"

        local-zone: "nflxext.com" typetransparent
        local-data: "nflxext.com IN AAAA ::2"

        local-zone: "nflximg.net" typetransparent
        local-data: "nflximg.net IN AAAA ::2"

        local-zone: "nflxvideo.net" typetransparent
        local-data: "nflxvideo.net IN AAAA ::2"

        local-zone: "www.netflix.com" typetransparent
        local-data: "www.netflix.com IN AAAA ::2"

        local-zone: "customerevents.netflix.com" typetransparent
        local-data: "customerevents.netflix.com IN AAAA ::2"

        local-zone: "secure.netflix.com" typetransparent
        local-data: "secure.netflix.com IN AAAA ::2"

        local-zone: "adtech.nflximg.net" typetransparent
        local-data: "adtech.nflximg.net IN AAAA ::2"

        local-zone: "assets.nflxext.com" typetransparent
        local-data: "assets.nflxext.com IN AAAA ::2"

        local-zone: "codex.nflxext.com" typetransparent
        local-data: "codex.nflxext.com IN AAAA ::2"

        local-zone: "dockhand.netflix.com" typetransparent
        local-data: "dockhand.netflix.com IN AAAA ::2"

        local-zone: "ichnaea.netflix.com" typetransparent
        local-data: "ichnaea.netflix.com IN AAAA ::2"

        local-zone: "art-s.nflximg.net" typetransparent
        local-data: "art-s.nflximg.net IN AAAA ::2"

        local-zone: "tp-s.nflximg.net" typetransparent
        local-data: "tp-s.nflximg.net IN AAAA ::2"
      forward-zone:
        name: "."
        forward-addr: 1.1.1.1@853
        forward-addr: 1.0.0.1@853
        forward-addr: 2606:4700:4700::2111@853
        forward-addr: 2606:4700:4700::2001@853
        forward-ssl-upstream: yes
    '';
  };
}
