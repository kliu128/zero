import { Secret } from "cdk8s-plus-22";
import { Construct } from "constructs";
import { config } from "./config.secret";
import { secretFrom } from "./util";
import { WebService } from "./web-service";

export class Transmission extends Construct {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // Store wireguard config
    const wgConfig = new Secret(this, "wireguard");
    wgConfig.addStringData("wg0.conf", config.cloudflareWarpConfig);

    new WebService(this, "transmission", {
      host: "transmission.kliu.io",
      image: "haugene/transmission-openvpn:wireguard",
      port: 9091,
      hostPaths: [
        {
          name: "incoming",
          hostPath: "/mnt/storage/Kevin/Incoming",
          containerPath: "/data",
        },
      ],
      volumes: [],
      additionalOptions: {
        env: [
          {
            name: "VPN_PROTOCOL",
            value: "wireguard",
          },
          {
            name: "LOCAL_NETWORK",
            value: "10.1.0.0/16",
          },
        ],
        envFrom: [
          {
            secretRef: {
              name: secretFrom(
                this,
                "transmission-config",
                config.transmissionConfig
              ).name,
            },
          },
        ],
        securityContext: {
          privileged: true,
          capabilities: {
            add: ["NET_ADMIN", "SYS_MODULE"],
          },
        },
        volumeMounts: [
          {
            name: wgConfig.name,
            mountPath: "/etc/transmission-vpn/wireguard/wg0.conf",
            subPath: "wg0.conf",
          },
        ],
      },
      additionalPodOptions: {
        volumes: [
          {
            name: wgConfig.name,
            secret: {
              secretName: wgConfig.name,
            },
          },
        ],
      },
    });
  }
}
