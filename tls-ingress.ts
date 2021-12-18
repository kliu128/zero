import { Ingress, IngressBackend, Secret, Service } from "cdk8s-plus-22";
import { Construct } from "constructs";

export class TlsIngress extends Construct {
  constructor(
    scope: Construct,
    id: string,
    options: { hosts: string[]; svc: Service }
  ) {
    super(scope, id);

    const tlsSecret = new Secret(this, "tls-secret");

    new Ingress(this, "ingress", {
      metadata: {
        annotations: {
          "cert-manager.io/cluster-issuer":
            "cert-manager-letsencrypt-cluster-issuer",
          "kubernetes.io/ingress.class": "public",
          "nginx.ingress.kubernetes.io/proxy-body-size": "4000m",
        },
      },
      rules: options.hosts.map((host) => ({
        host,
        path: "/",
        backend: IngressBackend.fromService(options.svc),
      })),
      tls: [
        {
          hosts: options.hosts,
          secret: { name: tlsSecret.name },
        },
      ],
    });
  }
}
