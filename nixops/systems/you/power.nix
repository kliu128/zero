{ config, lib, pkgs, ... }:

let
  batpro = pkgs.writeScript "batpro" ''
    #!${pkgs.stdenv.shell}

    # Copyright (C) 2019  Ayman Bagabas (ayman.bagabas@gmail.com), Evgeny Kuznetsov (evgeny@kuznetsov.md)
    # Licensed under GNU GPL v2.0

    # This script is designed to control battery protection feature on Huawei MateBook 13.

    _usage() {
      cat <<EOF
    USAGE:
    $0 [help|status|off|home|office|travel]
    $0 custom [1-100] [1-100]
    EOF
      for i in "''${!options[@]}"; do
        echo "	$i - ''${options[$i]}";
      done
    }

    _error() {
      echo "wrong input!
      "
      _usage
      exit 1
    }

    wait_read() {
      for i in {1..10000}; do
        if ! [ $((0x$(inb --hex $1) & 0x01)) -eq 0 ]; then
          break
        fi
        sleep 0.01
      done
      ! [ $i -eq 10000 ]
    }

    wait_write() {
      for i in {1..10000}; do
        if [ $((0x$(inb --hex $1) & 0x02)) -eq 0 ]; then
          break
        fi
        sleep 0.01
      done
      ! [ $i -eq 10000 ]
    }

    wait_read_ec() {
      wait_read 0x66
      return $?
    }

    wait_write_ec() {
      wait_write 0x66
      return $?
    }

    read_ec() {
      wait_write_ec && outb 0x66 0x80
      wait_write_ec && outb 0x62 $1
      wait_read_ec && res=$(inb 0x62)
      echo "REG[$1]==$(printf '0x%x' $res)" >&2
      return "$res"
    }

    write_ec() {
      read_ec $1
      echo "REG[$1]:=$2" >&2
      wait_write_ec && outb 0x66 0x81
      wait_write_ec && outb 0x62 $1
      wait_write_ec && outb 0x62 $2
      read_ec $1
    }

    thresh_set() {
      write_ec 0xe4 "$(printf '0x%x' "$1")"
      write_ec 0xe5 "$(printf '0x%x' "$2")"
    }

    bp_off() {
      thresh_set 0 100
    }

    # Check root
    if [ $(id -u) -ne 0 ]; then
      echo "This script must be run as root"
      exit 1
    fi

    # Check necessary packages
    if ! [ -x "$(command -v inb)" -a -x "$(command -v outb)" ]; then
      echo "ioport was not found!"
      echo "Please install ioport"
      exit 1
    fi

    case "$1" in
      "help")
        cat <<EOF
    When switched on, battery protection will allow charging
    only if battery level is below minimum,
    and only until maximum level is reached.
    Huawei provides 3 presets for levels, and you may also specify your own.
    EOF
        _usage
        cat <<EOF
    Options are:
        help   - this help information
        status - display current battery protection status
        off    - switch off battery protection
        home   - set minimum threshold to 40, maximum to 70
        office - set minimum threshold to 70, maximum to 90
        travel - set minimum threshold to 95, maximum to 100
        custom - set custom thresholds: min max
    EOF
        ;;
      "status")
        read_ec 0xe4
        vmin="$?"
        read_ec 0xe5
        vmax="$?"
        if [ "$vmin" -eq 0 ]; then
          echo "battery protection is off"
        else
          echo "battery protection is on"
          echo "thresholds:"
          echo "minimum" $vmin "%"
          echo "maximum" $vmax "%"
        fi
        ;;
      "off")
        bp_off
        ;;
      "home")
        bp_off
        thresh_set 40 70
        ;;
      "office")
        bp_off
        thresh_set 70 90
        ;;
      "travel")
        bp_off
        thresh_set 95 100
        ;;
      "custom")
        if [ "$2" -ge 1 -a "$2" -le 100 -a "$3" -ge 1 -a "$3" -le 100 ]; then
          bp_off
          thresh_set "$2" "$3"
        else
          _error
        fi
        ;;
      *)
        _usage
        ;;
    esac

    exit 0
  '';
in {
  services.tlp.enable = true; # For laptop
  services.tlp.extraConfig = ''
    CPU_BOOST_ON_BAT=1
  '';
  powerManagement.powertop.enable = true;

  systemd.services.set-battery-profile = {
    enable = true;
    path = [ pkgs.ioport ];
    description = "Set Matebook X Pro Battery Profile";
    serviceConfig = {
      # 40-70%
      ExecStart = "${batpro} home";
      RemainAfterExit = true;
      Type = "oneshot";
    };
    wantedBy = [ "multi-user.target" ];
  };
}
