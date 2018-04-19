{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  boot.kernelParams = [ "intel_iommu=on" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1184,10de:0e0a
  '';
  boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  # UAS for the Seagate Backup Plus Hub
  boot.initrd.kernelModules = [ "uas" ];
  # For evdev passthrough
  virtualisation.libvirtd.qemuVerbatimConfig = ''
    namespaces = []
    user = "kevin"
    cgroup_device_acl = [
      "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse",
      "/dev/input/by-id/usb-04d9_USB_Keyboard-event-kbd",
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
      "/dev/rtc","/dev/hpet", "/dev/vfio/vfio"
    ]
  '';
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  # Samba
  services.samba.enable = true;
  services.samba.syncPasswordsByPam = true;
  services.samba.nsswins = true;
  services.samba.shares = {
    storage = {
      browseable = "yes";
      comment = "Public samba share.";
      "guest ok" = "yes";
      path = "/mnt/storage";
      "read only" = false;
      "acl allow execute always" = true; # Allow executing EXEs
    };
  };
  networking.firewall.allowedTCPPorts = [ 139 445 ];
  networking.firewall.allowedUDPPorts = [ 137 138 ];
}
