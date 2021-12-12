import { Ingress, IngressBackend, Service } from "cdk8s-plus-22";
import {
  Quantity,
  KubeStatefulSet,
  KubePersistentVolumeClaimProps,
  VolumeMount,
  Container,
  Volume,
} from "./imports/k8s";
import { Construct } from "constructs";

export type WebServiceOptions = {
  image: string;
  port: number;
  host: string;
  volumes: { name: string; path: string; size: Quantity }[];
  hostPaths?: { name: string; containerPath: string; hostPath: string }[];
  additionalOptions?: Container;
};

export class WebService extends Construct {
  constructor(scope: Construct, id: string, options: WebServiceOptions) {
    super(scope, id);

    const labels = {
      app: id,
    };

    const volumeMounts: VolumeMount[] = [];
    const volumeClaimTemplates: KubePersistentVolumeClaimProps[] = [];
    options.volumes.forEach((vol) => {
      const name = `${id}-${vol.name}`;
      const claimTemplate: KubePersistentVolumeClaimProps = {
        metadata: {
          labels,
          name,
        },
        spec: {
          accessModes: ["ReadWriteOnce"],
          resources: {
            requests: {
              storage: vol.size,
            },
          },
        },
      };
      const volumeMount = {
        mountPath: vol.path,
        name,
      };

      volumeMounts.push(volumeMount);
      volumeClaimTemplates.push(claimTemplate);
    });
    const volumes: Volume[] = [];

    for (const { hostPath, containerPath, name } of options.hostPaths || []) {
      const volumeMount = {
        mountPath: containerPath,
        name,
      };
      volumeMounts.push(volumeMount);
      volumes.push({
        name,
        hostPath: {
          path: hostPath,
          type: "Directory",
        },
      });
    }

    if (options.additionalOptions?.volumeMounts) {
      volumeMounts.push(...options.additionalOptions.volumeMounts);
    }
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
                image: options.image,
                volumeMounts,
                ...options.additionalOptions,
              },
            ],
            volumes,
          },
        },
        volumeClaimTemplates,
      },
    });

    const svc = new Service(this, `${id}-service`, {
      ports: [{ port: options.port }],
    });
    svc.addSelector("app", id);

    new Ingress(this, `${id}-ingress`, {
      metadata: {
        annotations: {
          "cert-manager.io/cluster-issuer":
            "cert-manager-letsencrypt-cluster-issuer",
          "kubernetes.io/ingress.class": "public",
        },
      },
      rules: [
        {
          host: options.host,
          path: "/",
          backend: IngressBackend.fromService(svc),
        },
      ],
      tls: [
        {
          hosts: [options.host],
          secret: { name: `${id}-ingress-tls` },
        },
      ],
    });
  }
}
