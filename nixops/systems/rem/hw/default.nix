# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./kernel.nix
      ./me.nix
      ./mounts.nix
      ./snapraid.nix
      ./swap.nix
    ];
  
  # AMDGPU ROCM
  nixpkgs.overlays = [ (import (builtins.fetchTarball https://github.com/nixos-rocm/nixos-rocm/archive/master.tar.gz)) ];

  hardware.opengl.extraPackages = with pkgs; [
    rocm-opencl-icd
  ];
  environment.systemPackages = with pkgs; [
    rocminfo rocm-smi rocm-opencl-runtime
  ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ]; # for early KMS
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod" "uas" ];
  boot.kernelModules = [ "kvm-intel" "it87" ];
  
  # Video.
  console.earlySetup = true;
  services.xserver.videoDrivers = ["modesetting" "amdgpu" ];
  boot.kernelParams = [ "consoleblank=300" "amdgpu.dc=0" ];

  # Freeness (that is, not.)
  hardware.enableRedistributableFirmware = true; # for amdgpu
  hardware.cpu.intel.updateMicrocode = true;
  
  boot.cleanTmpDir = true;

  systemd.services.kube-container-clearer = {
    description = "Clear Broken Kubernetes Pods";
    path = with pkgs; [ kubectl gnugrep coreutils ];
    script = ''
      export KUBECONFIG=/etc/kubernetes/cluster-admin.kubeconfig
      for pod in $(kubectl get pod | grep CrashLoopBackOff | cut -d " " -f1); do
        if kubectl describe pod "$pod" | grep "OCI runtime create failed" >/dev/null; then
          echo "Deleting broken pod state $pod"
          kubectl delete pod --wait=false "$pod"
        fi
      done

      for pod in $(kubectl get pod | grep ImagePullBackOff | cut -d " " -f1); do
        kubectl delete pod --wait=false "$pod"
      done

      if kubectl logs --tail 200 matrix-puppet-discord-0 | grep "Unexpected token <"; then
        kubectl delete pod --wait=false matrix-puppet-discord-0
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wants = [ "kubernetes.target" ];
    after = [ "kubernetes.target" ];
    startAt = "minutely";
  };

  systemd.services.matrix-facebook-restart = {
    description = "Restart Matrix Facebook";
    path = with pkgs; [ kubectl ];
    script = ''
      export KUBECONFIG=/etc/kubernetes/cluster-admin.kubeconfig
      kubectl delete pod matrix-facebook-0
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wants = [ "kubernetes.target" ];
    after = [ "kubernetes.target" ];
    startAt = "*-*-* 05:00:00";
  };

  # Run continuously since Kubelet tries to enable panic_on_oops
  systemd.services.sysctl-adjust = {
    description = "Adjust Sysctl";
    path = with pkgs; [ procps ];
    script = ''
      sysctl -w kernel.panic_on_oops=0
      sysctl -w kernel.sysrq=1
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    startAt = "minutely";
  };
  # Renice
  systemd.services.renice = {
    description = "Renice services";
    path = with pkgs; [ utillinux coreutils procps ];
    script = ''
      chrt -p --rr -R -a 99 $(pgrep X) || true
      renice -n 5 -p $(pgrep z_wr_iss) $(pgrep z_rd_int) $(pgrep z_) $(pgrep spl_) $(pgrep nfs) $(pgrep xprtiod) || true
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    startAt = "minutely";
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto", ATTR{power/autosuspend}="300"
  '';

  # Proper shutdown in a timely manner
  # See https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
  systemd.extraConfig = ''
    ShutdownWatchdogSec=15
  '';
}
