{ config, lib, pkgs, ... }:

{
  boot.kernel.sysctl = {
    "kernel.panic_on_oops" = lib.mkForce 0;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_congestion_control" = "bbr";
  };
  boot.kernelPackages = pkgs.linuxPackages_5_2;

  # Workaround until https://bugzilla.kernel.org/show_bug.cgi?id=187421 is fixed
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="module", KERNEL=="fuse", RUN+="${pkgs.coreutils}/bin/sleep .5"
  '';
}
