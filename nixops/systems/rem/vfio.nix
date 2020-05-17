{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  boot.kernelParams = [
    # Turn on IOMMU for VFIO
    "intel_iommu=on" "iommu=pt"
    # Disable transparent hugepages; it makes QEMU take much longer to start,
    # as it has to allocate a ton of hugepages at the beginning, which can be
    # slow due to memory fragmentation.
    "transparent_hugepage=never"
  ];
  # Use vfio-pci for AMD RX 580
  boot.extraModprobeConfig = ''
    # options vfio-pci ids=1002:67df,1002:aaf0
  '';
  virtualisation.libvirtd.qemuVerbatimConfig = ''
    user = "kevin"
    group = "users"
    nographics_allow_host_audio = 1

    cgroup_device_acl = [
      "/dev/kvm",
      "/dev/input/by-id/usb-04d9_USB_Keyboard-event-kbd",
      "/dev/input/by-id/usb-Logitech_USB_Receiver-event-mouse",
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
      "/dev/rtc","/dev/hpet", "/dev/sev"
    ]
  '';
  boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  virtualisation.libvirtd.qemuRunAsRoot = true;
  boot.blacklistedKernelModules = [ "nouveau" ];
  # Allow kevin to manage libvirt
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];
}
