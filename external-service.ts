import { Service } from "cdk8s-plus-22";
import { Construct } from "constructs";
import { KubeEndpoints } from "./imports/k8s";
import { TlsIngress } from "./tls-ingress";

export class ExternalService extends Construct {
  constructor(
    scope: Construct,
    id: string,
    options: { ip: string; port: number; host: string }
  ) {
    super(scope, id);

    const svc = new Service(this, "svc", {
      clusterIP: "None",
      ports: [{ port: 80, targetPort: options.port }],
    });
    new KubeEndpoints(this, "endpoint", {
      metadata: {
        name: svc.name,
      },
      subsets: [
        {
          addresses: [{ ip: options.ip }],
          ports: [{ port: options.port }],
        },
      ],
    });

    new TlsIngress(this, "tls-ingress", {
      hosts: [options.host],
      svc: svc,
    });
  }
}
