{ config, lib, pkgs, ... }:

{
  networking.firewall.allowedTCPPorts = [ 8080 9005 ];
  users.users.aneesh = {
    uid = 1007;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBUlaS0Xpk78ZRNd4+UPfudiMfwd2HU1KvE1mVCMU/hiftqeaYMyUV0DuvQUGP0LR+x3caCusGeUcBaidd//h86k4ETRLiHvMyHcQfULai7JMtzbX2R+ot9pdCKfFSRLy0UMn6S/EU32cdilm54GypiJI4ltZvokT/GB4Y/6ll2JWZHsJJH136/DGqJ8FmlCWnMV98tTMr1lX05fMeuFVmyWMCswDhhlp5T/8atY94R4mp/y1SH2Kg97vKhETIlpCZo0Xzb/DRkbzFdpjj7B08L8LhIIm8ApK/Hmhy+329GEIWPmqYNqDQDP+2HXKNxDHKY9DJXSty95+Nh+sEs/+KZ jebikoh"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkpUUOJl0pm+No1Xs9JBh7E7mz2TiAuX8ozx64K2omPJCpD6T30fPaE4Oh/f8JGNkdt8eKg1rfSRNwzUx/vMSH76Ok8g09YmZoI0fEKmbgBeqZVHAgdW7us/44O9VgP1neODGJzUdUasipvIN3Pr30uxEfmqBEu2drpNVAUEBLxOcbUggbWOBo8cFyo6Z6j07IbrGKYmd0oj+XBZMe5I5KdX6VT2s+H+b2b2ee3n/t+q5lBpUNqEDnGGy8JSiIlDFF2da/uPhkluc1Nj8dJP/8TCbQftCWdiCDFG5xwTJl36nxnd4MMlNnsvIiQ8FiPgPzWPLOvotX9pCl4guerIxlp7McvoSWxezY4yYTOak5GlCH5fzZXUY/DOTMWLITg5tlQw2UHItmae6cOSpFkoUjM05Cotpn2i7f8TQnDLCMUboRbzZbS11oDTC9sJhqVgYpOD3AS+m6I2sPmbezm5xnl+3XSfmCwTnLGFWBehc9y3r6aUWYCKqsLP1rDV+aGUH1i8zfjw68g1fw1JeK7UU7n0LUOTAILb5a7WIpJhI0oy9x8rq8uVIUNI9GumnU5F6XB1WvidZc8nQAGdzCepSIXRB2CGeIRAYnmO4wB7COSbBrGzCtKO3pSe8GyLemLHuZrluPR3idn7MDVmnrjIC6BVK/BXld8EKV2D/kx2kKVQ== cardno:000607754603"
    ];
  };
  services.openssh.allowSFTP = false;
  services.openssh.extraConfig = ''
    Subsystem sftp internal-sftp
    Match User aneesh
      ChrootDirectory /srv/chroot
      AllowTCPForwarding no
      X11Forwarding no
      ForceCommand internal-sftp -d mc
  '';
  fileSystems."/srv/chroot/mc" = {
    device = "/srv/nfs/pvcs/default-mc-aneesh-vanilla-minecraft-datadir-pvc-24965e95-7f65-11e9-9b2b-74d435e2529b";
    options = [ "bind" ];
  };
}
