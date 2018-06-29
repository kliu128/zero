{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  boot.kernelParams = [
    # Turn on IOMMU for VFIO
    "intel_iommu=on"
    # Disable transparent hugepages; it makes QEMU take much longer to start,
    # as it has to allocate a ton of hugepages at the beginning, which can be
    # slow due to memory fragmentation.
    "transparent_hugepage=never"
  ];
  # Use vfio-pci for NVIDIA GTX 770
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1184,10de:0e0a
  '';
  boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  # For evdev passthrough
  virtualisation.libvirtd.qemuVerbatimConfig = ''
    namespaces = []
    user = "kevin"
    cgroup_device_acl = [
      "/dev/input/by-id/usb-Logitech_USB_Receiver-event-mouse",
      "/dev/input/by-id/usb-04d9_USB_Keyboard-event-kbd",
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
      "/dev/rtc","/dev/hpet", "/dev/vfio/vfio"
    ]
  '';
  # Allow kevin to manage libvirt
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  programs.zsh.interactiveShellInit = ''
    vm-start() {
      touch /dev/shm/looking-glass || true
      chown kevin:libvirtd /dev/shm/looking-glass
      chmod 660 /dev/shm/looking-glass
      sudo virsh start Windows
    }
  '';
}
