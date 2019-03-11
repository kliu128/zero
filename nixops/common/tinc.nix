{ config, lib, pkgs, ... }:

{
  networking.hosts = {
    "10.99.0.1" = ["rem.i.potatofrom.space"];
    "10.99.0.2" = ["otto.i.potatofrom.space"];
    "10.99.0.3" = ["puck.i.potatofrom.space"];
  };
  services.tinc.networks."omnimesh"= {
    interfaceType = "tap";
    chroot = false;
    extraConfig = ''
      Mode = switch
      AutoConnect = yes
    '';
    hosts = {
      rem = ''
        Compression = 10
        Address = potatofrom.space 655
        Ed25519PublicKey = T7VbcnZFoMzNZh6mpP1m8hqMgdw7bDqrfrO/TFZZlAI

        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAwcRX8uz+H4owM+z72r2XvVFU/CINpsiuVbdP/dVcKSEGc+Z1RUzE
        l8GvmeNGg5R+cMNYoxfpYaLwDDSMixt2aT8l3og8M1IggOsAua71TtZhmNotEl+I
        5gX+CJYYwgRJm4eY5pJcnICnb/+QKgkrzvUYAnbwZaNS08Zt1lr1FpF8leFokFMU
        AeoArOvsf9qCawDMuHwJdXNd2fEqmwpVt3i0d3mANFXPR6jf/J59kBdbBpVKLnMg
        EKBwcqRIWKKz9lpD7e7xMnyiDfVv3f9Uw75oLmqVaWfI5kGAv7VisvHCO+XVcRGj
        0OFKRDS8orbkioy0WOIOUVAgkbBPayxAkFdz2m4MAUDrNJwXIyv2GEo72Jy49PBJ
        QzAJlM8hiD+D08zlwRZQQM5WDkL1Sfwjzet6z7GWZqzczp8wMPgL0DIRroWDX+/G
        xOXY+NVD1/qxV2flkxiiKpE6yOnAbaJwrHRKYiQ7yh1K9pVU83LCiGPPoIc7dJGF
        9V8pl4hn7HRNqWWqNtyCT2yAg026Ows1ph1dFT0pDUJeGH/LAJgLzWpi80yvURls
        4AJYUc9WHs0G9JtYln8saFCYaFXRVlD92bldthXuaUalH/BRcBvTvYCz+00Der4x
        iQB8PPr1bq2qqslUmYjAj5XUzniNohcilSs8v2oMbNtACDWoweNO9NMCAwEAAQ==
        -----END RSA PUBLIC KEY-----
        '';
      otto = ''
        Compression = 10
        Address = 192.168.1.11
        Port = 655
        Ed25519PublicKey = ojKpm3CHG06B+2ugM5HFHtOlssQ9g3WGplGINk3h/LO

        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEA4TSibLys3gXeaXCF41QnR7enwAwoJOPiFTPtG4um5doNS0CF79ez
        EhiqYCISJlVyDKpOHneL/pGBUGF6wAwvewvKsZIYR2LEUAyz5bQxjyJV2S1RdK/j
        V8U1sqbv06R2WFJBnMr4Mqte7tPs462/7ndWYFdWZJ4Gu28LZ5ATyP/zD5A11jJo
        +Ba9w2BYG48UqQkB77SJbI5/fWSIg1hwOTBh/1zz9/JeLoOLOJxmHiQqzpnHhc1q
        g/D5sByfo6XHUQBPym9kaQcFjGZK3sgbBW5YUGZoj9EWlrUrknX4IU9eBjyq/m8N
        AMlonKuEUHaslW7X5GfLDVhgHGGfMRXP1e99E10wvUuJBHFLpBwtzjlQBs/00WQT
        fONp2EnwMhUqtywi+6G7xJZF8M3HwSL+OdNUTw4GRHvKbIR8B4irFkfqosr9melV
        6GXih/z3Tsc6CP+QRDsFvo6Gt41gvfRBRMHjbWKUSdC2ekVy2EKUmrdFifA0dHSa
        YNWwuIrvK/hILcVZ0iYJC9S3wDWkZHFu8EcmEotEnadLPC6iLPamnvmRrpe8TV7v
        vf+/QKotJFMUqh5ll8pu4jodXonnMJJN/QfBJ57mad60T7oXbzplbmS9sqoUpwSU
        P4Q8pjAiqocAr8BRf5A1PcAPvlpFW3tZFpCVthQyh/+dIRXVx647NfsCAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
      puck = ''
        Compression = 10
        Ed25519PublicKey = V4//lY5FierUZvtbDt92cUIOS4pMf87Zm7HsTsj25TB
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAreVL2TENzNGvKTg9r/hZSFUwGp/uF9oqVIMzyApI3mUMKM/7XJ2t
        lTMjSBqFMzplCkaVxiw5T4MwgMzwUWByUTKRKFZJS2nDZzZup6HPwMSctGP2B3as
        5hZBvxjjogwfrJy5IqoHZ25OA6a3oqdv9et1W/zRN8Ar0WcleDR6Ugn6pGLWO/QO
        wRRLmgBBlmOH6CM8QkJMSUYsviSF6PSvrBDzEOBZSFBoFgAQ2YW83+Bpq5byn+8M
        V26ROj1+UzqZBFFvInOmHZe9ezpKpgCqQ35Tol8YGwIQnvkKwtVrYXb8hV+PMrxa
        2W4uBEbZgY2ZUMdNV18f0DtvyOsrCX9sOffVBnnXWouyM9zLZpXpxDrxVh3at5nS
        PCtBoyB2xwE/50Ot348nuqa2j8XVOVDVejReDGorSpQrOszvbedDuO3oa7iGawGl
        it7/c7Z+URP/nx+zN2Nusr+v7WRpziUgucsUgp5XGQYh1hO1A5xNV8bjdbP187e9
        yZdV7xxvZ3m8G4dHVwTipT7wtBg0pzflloDXGlXkdIsyAbG/MdvtIniRRaYK52DH
        0y5I4dIpHxwbLO9+xZRi1dBJoiBNT7ynXSUztM7wa0RWGcKp3cf5GkRNBgL76a5F
        MyrrG+I440h6hfUR5vkSdzVi7mpYqLCJEzhe2UgeXQMNRIUYkoy4J58CAwEAAQ==
        -----END RSA PUBLIC KEY-----
      '';
    };
  };
  networking.firewall.allowedTCPPorts = [ 655 ];
  networking.firewall.allowedUDPPorts = [ 655 ];
  systemd.services."network-addresses-tinc.omnimesh".after = [ "tinc.omnimesh.service" ];
  systemd.services."network-link-tinc.omnimesh".after = [ "tinc.omnimesh.service" ];
  systemd.services."tinc.omnimesh".restartIfChanged = false;
}