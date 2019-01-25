{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    simple-scan
  ];

  # Scanner
  hardware.sane.enable = true;
  hardware.sane.netConf = "localhost";

  systemd.services.scanbd = {
    enable = true;
    description = "SANE Scanner Button Daemon";
    path = [ pkgs.scanbd ];
    script = "scanbd -f -c ${./scanbd.conf}";
    wantedBy = [ "multi-user.target" ];
  };
  # systemd.services."scanbm@" = {
  #   enable = true;
  #   unitConfig.Requires = "scanbm.socket";
  #   serviceConfig = {
  #     ExecStart = "${pkgs.scanbd}/bin/scanbm -c ${./scanbd.conf}";
  #     StandardInput = "socket";
  #   };
  # };
  # systemd.sockets."scanbm" = {
  #   enable = true;
  #   socketConfig = {
  #     ListenStream = 6566;
  #     Accept = true;
  #     MaxConnections = 1;
  #   };
  #   wantedBy = [ "sockets.target" ];
  # };
  environment.etc."scan.sh" = {
    text = ''
      #!/bin/sh
      set -x

      date="$(${pkgs.coreutils}/bin/date)"
      exec 3>&1 1>>"/srv/paperless-incoming/$date.log" 2>&1
      tmpdir="$(mktemp -d)"
      pushd "$tmpdir"

      ${pkgs.sane-backends}/bin/scanimage --batch=out%d.jpg --format=jpeg --mode Gray -d "fujitsu:ScanSnap S500M:4530" --source "ADF Duplex" --resolution 300
      
      for i in out*.jpg; do ${pkgs.imagemagick}/bin/convert $i ''${i//jpg/pdf}; done

      ${pkgs.ghostscript}/bin/gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="/srv/paperless-incoming/Scan $date.pdf" -dBATCH `${pkgs.coreutils}/bin/ls -v out*.pdf`
      ${pkgs.coreutils}/bin/chown -R kevin:users /srv/paperless-incoming

      popd
      rm -r "$tmpdir"
    '';
    mode = "0700";
  };
}
