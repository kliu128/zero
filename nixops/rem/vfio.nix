{ config, lib, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  boot.kernelParams = [
    # Turn on IOMMU for VFIO
    "intel_iommu=on"
    # Disable transparent hugepages; it makes QEMU take much longer to start,
    # as it has to allocate a ton of hugepages at the beginning, which can be
    # slow due to memory fragmentation.
    # "transparent_hugepage=never"
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
    cgroup_device_acl = [
      "/dev/input/by-id/usb-Logitech_USB_Receiver-if02-event-mouse",
      "/dev/input/by-id/usb-04d9_USB_Keyboard-event-kbd",
      "/dev/null", "/dev/full", "/dev/zero",
      "/dev/random", "/dev/urandom",
      "/dev/ptmx", "/dev/kvm", "/dev/kqemu",
      "/dev/rtc","/dev/hpet", "/dev/vfio/vfio"
    ]
  '';
  virtualisation.libvirtd.qemuRunAsRoot = true;
  # Allow kevin to manage libvirt
  users.extraUsers.kevin.extraGroups = [ "libvirtd" ];

  programs.zsh.interactiveShellInit = ''
    vm-start() {
      touch /dev/shm/looking-glass || true
      chown kevin:libvirtd /dev/shm/looking-glass
      chmod 660 /dev/shm/looking-glass
      sudo /etc/libvirt/hooks/qemu Windows prepare begin -
      sudo virsh start Windows
    }

    vm-stop() {
      sudo virsh shutdown Windows
      echo "Press [Enter] key when shutdown..."
      read -n 1
      sudo /etc/libvirt/hooks/qemu Windows release end -
    }
  '';

  environment.systemPackages = with pkgs; [ cpuset looking-glass-client ];
  environment.etc."libvirt/hooks/qemu" = {
    source = ./vfio.sh;
    mode = "777";
  };

  networking.bridges.br0 = {
    interfaces = [ "eth0" ];
  };
  systemd.services.coder = {
    enable = false;
    description = "VSCode Coder Service";
    path = [ pkgs.systemd ];
    script = "systemd-nspawn -bUD /var/lib/machines/coder";
    wantedBy = [ "multi-user.target" ];
  };
  virtualisation.anbox.enable = true;
  systemd.network.netdevs.anbox-dummy = {
    enable = true;
    netdevConfig.Name = "anbox-dummy";
    netdevConfig.Kind = "dummy";
  }; 
  systemd.network.networks.anbox-dummy = {
    enable = true;
    matchConfig.Name = "anbox-dummy";
    networkConfig = {
      Bridge = "anbox0";
      DHCP = "no";
    };
  }; 

  # Patch for better PulseAudio (for QEMU 2.12)
  # nixpkgs.config.packageOverrides = pkgs: rec {
  #   qemu = pkgs.qemu.overrideAttrs (oldAttrs: rec {
  #     patches = (pkgs.fetchpatch {
  #       url = "https://github.com/qemu/qemu/compare/master...spheenik:2.12.0-patched.patch";
  #       name = "qemu-pa-2.12.patch"; # Required due to https://github.com/NixOS/nixpkgs/issues/44949
  #       sha256 = "0wzp0s6na7scf2z19zm0cyk58rdxc39fk3gksj53hi3d03r3vzss";
  #     });
  #   });
  # };
}
