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
    serviceConfig = {
      Type = "forking";
      ExecStart = "${pkgs.scanbd}/bin/scanbd --debug=2 --config=${./scanbd.conf}";
      Restart = "always";
    };
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
      export PATH=${lib.makeBinPath [ pkgs.coreutils pkgs.sane-backends pkgs.imagemagick pkgs.ghostscript ]}
      set -x

      # Paperless date format - see https://github.com/the-paperless-project/paperless/blob/e3a616ebc3796f65f8c780daa13044aa0c380fe8/docs/guesswork.rst
      date="$(date --utc +'%Y%m%d%H%M%SZ')"
      filename="$date - Untitled Scan.pdf"
      tmpdir="$(mktemp -d)"
      pushd "$tmpdir"

      scanimage --batch=out%d.jpg --format=jpeg --mode Color -d "fujitsu:ScanSnap S500M:4530" --source "ADF Duplex" --resolution 150
      
      for i in out*.jpg; do convert $i ''${i//jpg/pdf}; done

      gs -dNOPAUSE -sDEVICE=pdfwrite -sOUTPUTFILE="/srv/paperless-incoming/$filename" -dBATCH `ls -v out*.pdf`
      chown -R kevin:users /srv/paperless-incoming

      popd
      rm -r "$tmpdir"
    '';
    mode = "0700";
  };
}
