{ config, lib, pkgs, ... }:

{
  # Enable Wireguard
  networking.wireguard.interfaces = {
    # "wg0" is the network interface name. You can name the interface arbitrarily.
    wg0 = {
      # Determines the IP address and subnet of the client's end of the tunnel interface.
      ips = [ "10.100.0.2/24" ];

      # Path to the private key file.
      #
      # Note: The private key can also be included inline via the privateKey option,
      # but this makes the private key world-readable; thus, using privateKeyFile is
      # recommended.
      privateKey = builtins.readFile ../secrets/wireguard/puck-privatekey;

      peers = [
        # For a client configuration, one peer entry for the server will suffice.
        {
          # Public key of the server (not a file path).
          publicKey = (import ../wireguard.nix).keys.rem;

          # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
          # For a server peer this should be the whole subnet.
          allowedIPs = [ (import ../wireguard.nix).subnet ];

          # Set this to the server IP and port.
          endpoint = "potatofrom.space:53";

          # Send keepalives every 25 seconds. Important to keep NAT tables alive.
          persistentKeepalive = 25;
        }
      ];
    };
  };

  # Make more reliable with wifi
  systemd.services.wireguard-wg0.serviceConfig.Type = lib.mkForce "simple";
  systemd.services.wireguard-wg0.serviceConfig.Restart = "always";
  systemd.services.wireguard-wg0.unitConfig.StartLimitIntervalSec = 0;
  systemd.services.wireguard-wg0.preStart = "ip link del wg0 || true";
}
