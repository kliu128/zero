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
  # # Use vfio-pci for NVIDIA GTX 770
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:1184,10de:0e0a
  '';
  virtualisation.libvirtd.qemuVerbatimConfig = ''
    user = "kevin"
    group = "users"
    nographics_allow_host_audio = 1
  '';
  boot.kernelModules = [ "vfio" "vfio_iommu_type1" "vfio_pci" "vfio_virqfd" ];
  boot.blacklistedKernelModules = [ "nouveau" ];
  virtualisation.libvirtd.qemuRunAsRoot = true;
  # Allow kevin to manage libvirt
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];
}
