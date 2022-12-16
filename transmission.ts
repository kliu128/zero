import { Secret } from "cdk8s-plus-22";
import { Construct } from "constructs";
import { config } from "./config.secret";
import { makeEnvObject, secretFrom } from "./util";
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
        {
          name: "completed",
          hostPath: "/mnt/stor/Inbox",
          containerPath: "/completed",
        },
      ],
      volumes: [],
      additionalOptions: {
        env: makeEnvObject({
          VPN_PROTOCOL: "wireguard",
          LOCAL_NETWORK: "10.1.0.0/16",
          TRANSMISSION_RATIO_LIMIT: "2",
          TRANSMISSION_RATIO_LIMIT_ENABLED: "true",
        }),
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
