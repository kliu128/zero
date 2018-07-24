{ config, lib, pkgs, ... }:

{
  # Ensure IP forwarding is enabled.
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;

  # Add a masquerade rule to iptables so the clients can talk to one another
  networking.firewall.extraCommands = ''
    iptables -t nat -A POSTROUTING -s10.100.0.0/24 -j MASQUERADE
  '';

  networking.firewall.allowedUDPPorts = [ 51820 ];

  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "${(import ../wireguard.nix).ips.rem}/24" ];

      # The port that Wireguard listens to. Must be accessible by the client.
      listenPort = 51820;

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKey = builtins.readFile ../secrets/wireguard/rem-privatekey;

      peers = [
         { # Puck
          # Public key of the peer (not a file path).
          publicKey = (import ../wireguard.nix).keys.puck;
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "${(import ../wireguard.nix).ips.puck}/32" ];
        }
      ];
    };
  };
}
