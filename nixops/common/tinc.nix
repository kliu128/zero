{ config, lib, pkgs, ... }:

{
  networking.hosts = {
    "10.99.0.1" = ["rem.i.potatofrom.space" "rem"];
    "10.99.0.3" = ["puck.i.potatofrom.space"];
    "10.99.0.4" = ["you.i.potatofrom.space"];
    "10.99.0.5" = ["karmaxer.i.potatofrom.space"];
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
        Compression = 1
        Subnet = 0.0.0.0/0
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
      puck = ''
        Compression = 1
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
      momo = ''
        Compression = 1
        -----BEGIN RSA PUBLIC KEY-----
        MIIBCgKCAQEAoF/cvSKWBniIEOGQpZ56hug3Ticp7fgEq71mkCGpYk9o+5gm3qjo
        OpsNdPJ/RiEzrJsLRpvkj15J4fduh8XBsRNRR6VF6G+21SH5EA1OK/xKQqB4mvcN
        kHE+C3p8PoDiTa3k3xI5XwTC6QnIqKetEG82eE38mwBf2i4sCHfTBdPc3GOc8A75
        aleLfPKSNo3Rx3+WtpISQDqi1XPtEYWRomDTThWCsZwBhk5DluQjRg/XiPpQRzgc
        06WC9BBsPg5tjGnFfk1SZ3WLo954vZdum1Jle/Vq7k3ij7BoNVBl3bV+drMAYcuO
        sAJSVJQFf28/LWf5IAn50jRMvcC2IFWFgQIDAQAB
        -----END RSA PUBLIC KEY-----
        Ed25519PublicKey = Zexdm7zGAEakqj4JGYYKawKcyDm80iaCktt0k+Va66F
      '';
      you = ''
        Compression = 1
        -----BEGIN RSA PUBLIC KEY-----
        MIIBCgKCAQEAvRMf+bEagxHtKFb9XtVyfqf2xyWJC6aeTQ74Fp+Rss0ZyifcWOQn
        +WwqsvLb0PIWrFouZIztSzQwRlOBWFq8TJJuQQFnubDslYxsMUcZLY72OKelB8SK
        Iw7wG+pwv8eYVrCh8orN4bSbLBXk1wq1MPnffRLXvHIdZwtFI5en0Bb06PyGJyDv
        pQFItzY0A3yo4ABJqO1N33SRdhF+f1ji38F7U+Yz8PQhTwR8uBsuA+JKO4KOiFJ5
        pfiKIe+Rta+/O/xDxSGN5iGTnQzgxVmyRA1lzFl1titz92CTzy2aSY2HhtQ/WExx
        stEdeUV3ytGyuPWp3kbf1UoLb2InD2pGYwIDAQAB
        -----END RSA PUBLIC KEY-----
        Ed25519PublicKey = MTcrqYlHJAZAu3NvePmF1R+2HKuOj5a6/zLXVz5Ic/C
      '';
      karmaxer = ''
        Compression = 1
        Ed25519PublicKey = lbHbBMQJvi8j/KkmMl/sGKu1R2M7mjsgS6t2nIO9vLJ
        -----BEGIN RSA PUBLIC KEY-----
        MIICCgKCAgEAwi31odnkHcex14Vn0XSe1gcZRXld+x3Ms4nAZ8poYW3DugInCRT+
        e9gH4IZGDTXqEnQfDfCa29rUdwyP+gVoGanK0qYka+iKlTi/H8hjDj3X+172Oebt
        sdj2uV/oGEdTGriDUTsuf9d6YRHdgOPqNlNw0kgeTC8fKjplPDIwyr17wH8TchHp
        ubRmAqW3Za5FerdJdkrapTQx35ecLvOjw2DIB+YuUL5MiJ2jPOcLOXU4gfZRvDub
        vCCGpmPvFzayISMD8avGByL5RCohBhMmcjpTrFVJuAJ17tviAnwQIbY0IhjOo1CT
        KTk/SUOZtpXr8kCXTM5OsAwl6Pg8OyVcbpV14egeaqZ0GevK5hTgyhnPbqt4YLRX
        nqd5ikIhVftq9yJlEqaA/yN9J7zPMNVuh33Qw9PF98VHiShjXMS0lt3y5tRYmk+e
        kvwCciUeBo7J8uCT2oQhJu3djXkVqdFskjAIpk7L5eAMEq77fy8j9GuZNonGe5v4
        reg+KkOp2mmqgcjHmWByBXZWjkyoiKFON5pLhYmjaVoy288OHxCF26sUWapjXx3K
        yuMpjfEoXBmdX65Ym7oBrY/djJRXjc+vW7yIgP1RnhdtLPlRG2X8bwvFUN1wtKc+
        fL3/bLePwsCzZokdW4ASKK5fk4HJ3uYKtRqAfIpT45ahDaFq0U8j5qUCAwEAAQ==
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