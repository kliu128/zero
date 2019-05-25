{ config, lib, pkgs, ... }:
{
  # U2F
  hardware.u2f.enable = true;
  services.pcscd.enable = true;

  environment.systemPackages = with pkgs; [
    # U2F
    yubikey-personalization-gui yubikey-manager
  ];
  services.udev.packages = [ pkgs.yubikey-personalization-gui ];

  services.udev.extraRules = ''
    ACTION=="remove", ENV{ID_BUS}=="usb", ENV{ID_MODEL_ID}=="0407", ENV{ID_VENDOR_ID}=="1050", RUN+="${pkgs.bash}/bin/bash /etc/lock.sh"
  '';

  services.actkbd = {
    enable = true;
    bindings = [
      # Shift key - create /tmp/inhibit_yubikey_lock on press, delete on
      # release
      { keys = [ 1 ];
        events = [ "key" ];
        command = "${pkgs.coreutils}/bin/touch /tmp/inhibit_yubikey_lock"; }
      { keys = [ 1 ];
        events = [ "rel" ];
        command = "${pkgs.coreutils}/bin/rm /tmp/inhibit_yubikey_lock"; }
    ];
  };
  systemd.tmpfiles.rules = [
    # Remove inhibit marker on boot to avoid stuck conditions
    "r! /tmp/inhibit_yubikey_lock"
  ];

  environment.etc."lock.sh".source = pkgs.writeScript "lock" ''
    #!${pkgs.stdenv.shell}
    export PATH=${lib.makeBinPath [ pkgs.systemd pkgs.xorg.xset pkgs.sway ]}

    if [ ! -f /tmp/inhibit_yubikey_lock ]; then
      loginctl lock-sessions
    fi

    SWAYSOCK=$(echo /run/user/1000/sway*.sock) swaylock
  '';

  security.pam.services.login.u2fAuth = true;
  security.pam.services.swaylock.u2fAuth = true;
  security.pam.services.sudo.u2fAuth = true;
  security.pam.u2f = {
    control = "sufficient";
    authFile = ./u2f-mappings;
  };
}
