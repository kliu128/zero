import { Chart, Include } from "cdk8s";
import { Secret } from "cdk8s-plus-22";
import { Construct } from "constructs";
import { config } from "./config.secret";
import { ClusterIssuer } from "./imports/cert-manager.io";

export class CertManager extends Chart {
  constructor(scope: Construct, id: string) {
    super(scope, id, {
      namespace: "cert-manager",
      labels: {
        "io.kliu/prune-key": "cdk8s-zero",
      },
    });
    const certManager = new Include(this, id + "-cert-manager", {
      url: "https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.yaml",
    });
    const cfApiToken = new Secret(this, id + "-cloudflare-api-token");
    cfApiToken.addStringData("token", config.letsEncryptCloudflareApiToken);
    new ClusterIssuer(this, id + "-cluster-issuer", {
      metadata: {
        name: id + "-letsencrypt-cluster-issuer",
      },
      spec: {
        acme: {
          email: "kevin@kliu.io",
          server: "https://acme-v02.api.letsencrypt.org/directory",
          privateKeySecretRef: {
            name: id + "-letsencrypt-cluster-issuer-private-key",
          },
          solvers: [
            {
              dns01: {
                cloudflare: {
                  email: "kevin@kliu.io",
                  apiTokenSecretRef: {
                    name: cfApiToken.name,
                    key: "token",
                  },
                },
              },
            },
          ],
        },
      },
    }).addDependency(certManager);
  }
}
