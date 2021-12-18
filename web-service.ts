import { Service } from "cdk8s-plus-22";
import {
  Quantity,
  KubeStatefulSet,
  KubePersistentVolumeClaimProps,
  VolumeMount,
  Container,
  Volume,
  PodSpec,
} from "./imports/k8s";
import { Construct } from "constructs";
import { TlsIngress } from "./tls-ingress";
import { isArray, mergeWith } from "lodash";

export type WebServiceOptions = {
  image: string;
  port: number;
  host: string;
  volumes: { name: string; path: string; size: Quantity }[];
  hostPaths?: { name: string; containerPath: string; hostPath: string }[];
  additionalOptions?: Partial<Container>;
  additionalPodOptions?: Partial<PodSpec>;
};

/**
 * Merges the given objects into a single object while preserving individual
 * objects if they are in an array.
 */
function mergeArrayConcat(object: any, ...sources: any[]) {
  return mergeWith(object, ...sources, (objValue: any, srcValue: any) => {
    if (isArray(objValue)) {
      return objValue.concat(srcValue);
    }
    return undefined;
  });
}

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

    const ctrSpec: Container = mergeArrayConcat(
      {
        name: id,
        image: options.image,
        volumeMounts,
      },
      options.additionalOptions
    );
    const podSpec: PodSpec = mergeArrayConcat(
      {
        containers: [ctrSpec],
        volumes,
      },
      options.additionalPodOptions
    );

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
          spec: podSpec,
        },
        volumeClaimTemplates,
      },
    });

    const svc = new Service(this, `${id}-service`, {
      ports: [{ port: options.port }],
    });
    svc.addSelector("app", id);
    new TlsIngress(this, "tls-ingress", {
      hosts: [options.host],
      svc,
    });
  }
}
