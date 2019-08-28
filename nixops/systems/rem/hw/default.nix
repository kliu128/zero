# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
      ./amd-fan.nix
      ./kernel.nix
      ./me.nix
      ./mounts.nix
      ./swap.nix
    ];

  # Boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.kernelModules = [ "amdgpu" ]; # for early KMS
  boot.initrd.availableKernelModules = [ "ehci_pci" "ahci" "xhci_pci" "usb_storage" "usbhid" "sd_mod" "sr_mod" "uas" ];
  boot.kernelModules = [ "kvm-intel" ];
  
  # Video.
  boot.earlyVconsoleSetup = true;
  services.xserver.videoDrivers = [ "modesetting" "amdgpu" ];
  boot.kernelParams = [ "consoleblank=300" ];

  # Freeness (that is, not.)
  hardware.enableRedistributableFirmware = true; # for amdgpu
  hardware.cpu.intel.updateMicrocode = true;
  
  boot.cleanTmpDir = true;

  systemd.services.renice = {
    enable = true;
    description = "Renice services for increased responsiveness";
    path = [ pkgs.coreutils pkgs.procps ];
    script = ''
      while true; do
        renice -n 5 -p $(pgrep --parent 2 z) 2>/dev/null >/dev/null || true
        renice -n 5 -p $(pgrep --parent 2 spl) 2>/dev/null >/dev/null || true
        sleep 0.5
      done
    '';
    wantedBy = [ "multi-user.target" ];
  };

  # Reset keyboard on bootup (Pok3r)
  # Otherwise keys get dropped, for some reason
  # Same with webcam - mic breaks
  systemd.services.keyboard-webcam-reset = {
    description = "Keyboard & Webcam Pro 9000 Reset";
    script = ''
      set -x
      for X in /sys/bus/usb/devices/*
      do
          if [ -e "$X/idVendor" ] && [ -e "$X/idProduct" ] \
          && [ 046d = $(cat "$X/idVendor") ] && [ 0809 = $(cat "$X/idProduct") ]
          then
              echo 0 >"$X/authorized"
              sleep 1
              echo 1 >"$X/authorized"
          fi
      done
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services.drop-caches = {
    description = "Drop caches to increase system responsiveness";
    path = [ pkgs.gawk ];
    script = ''
      set -euo pipefail
      while true; do
        while [ "$(awk '/MemFree/ { printf "%.0f\n", $2 }' /proc/meminfo)" -gt 512000 ]; do
          sleep 1
        done
        echo Free memory reached lower limit, dropping caches.
        echo 3 > /proc/sys/vm/drop_caches
      done
    '';
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services.kube-container-clearer = {
    description = "Clear Broken Kubernetes Pods";
    path = with pkgs; [ kubectl gnugrep coreutils ];
    script = ''
      set -euo pipefail
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
    '';
    serviceConfig = {
      Type = "oneshot";
    };
    wants = [ "kubernetes.target" ];
    after = [ "kubernetes.target" ];
    startAt = "minutely";
  };

  # Proper shutdown in a timely manner
  # See https://utcc.utoronto.ca/~cks/space/blog/linux/SystemdShutdownWatchdog
  systemd.extraConfig = ''
    ShutdownWatchdogSec=15
  '';
}
