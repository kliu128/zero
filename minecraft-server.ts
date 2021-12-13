import { Construct } from "constructs";
import { KubeStatefulSet, Quantity } from "./imports/k8s";

export type MinecraftServerProps = {
  type: "FORGE" | "PAPER" | "VANILLA";
  version: string;
  // in MB
  memory: number;
  port: number;
  javaVersion?: string;
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
                name: "minecraft",
                tty: true,
                stdin: true,
                image:
                  "itzg/minecraft-server:" + (options.javaVersion ?? "latest"),
                env: [
                  {
                    name: "EULA",
                    value: "TRUE",
                  },
                  {
                    name: "VERSION",
                    value: options.version,
                  },
                  {
                    name: "MEMORY",
                    value: options.memory + "M",
                  },
                ],
                resources: {
                  limits: {
                    memory: Quantity.fromString(options.memory + "Mi"),
                  },
                },
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
              accessModes: ["ReadWriteOnce"],
              resources: {
                requests: {
                  storage: Quantity.fromString("10Gi"),
                },
              },
            },
          },
        ],
      },
    });
  }
}
