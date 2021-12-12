import { Construct } from "constructs";
import { KubeStatefulSet, Quantity } from "./imports/k8s";

export type MinecraftServerProps = {
  version: string;
  memory: string;
  port: number;
};

export class MinecraftServer extends Construct {
  constructor(scope: Construct, id: string, options: MinecraftServerProps) {
    super(scope, id);

    // chicken.jpeg!
    const labels = {
      app: id,
    };

    const volName = `${id}-data`;

    new KubeStatefulSet(this, id + "-statefulset", {
      metadata: {
        labels,
        name: id,
      },
      spec: {
        serviceName: id,
        selector: {
          matchLabels: labels,
        },
        template: {
          metadata: {
            labels,
          },
          spec: {
            containers: [
              {
                name: id,
                tty: true,
                image: "itzg/minecraft-server",
                ports: [
                  {
                    containerPort: 25565,
                    hostPort: options.port,
                  },
                ],
                volumeMounts: [
                  {
                    mountPath: "/data",
                    name: volName,
                  },
                ],
              },
            ],
          },
        },
        volumeClaimTemplates: [
          {
            metadata: {
              labels,
              name: volName,
            },
            spec: {
              resources: {
                requests: {
                  storage: Quantity.fromString("10Gb"),
                },
              },
            },
          },
        ],
      },
    });
  }
}
