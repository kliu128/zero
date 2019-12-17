{ config, lib, pkgs, ... }:

{
# enable NAT
  networking.nat.enable = true;
  networking.nat.externalInterface = "br0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];

   # This allows the wireguard server to route your traffic to the internet and hence be like a VPN
   # For this to work you have to set the dnsserver IP of your router (or dnsserver of choice) in your clients
   extraCommands = ''
    iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o br0 -j MASQUERADE
    '';
  };

  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the server's end of the tunnel interface.
      ips = [ "10.100.0.1/24" ];

      # The port that Wireguard listens to. Must be accessible by the client.
      listenPort = 51820;

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKey = builtins.readFile ../../secrets/wg-rem.private;

      peers = [
        # List of allowed peers.
        { # Feel free to give a meaning full name
          # Public key of the peer (not a file path).
          publicKey = "yx1c9wYX5A/ATfMbPGMXwffsbZk1R52TlXisL019bCc=";
          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };
}
