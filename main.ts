import { Construct } from "constructs";
import { App, Chart, ChartProps } from "cdk8s";
import { WebService, WebServiceOptions } from "./web-service";
import { KubeEndpoints, Quantity } from "cdk8s-plus-22/lib/imports/k8s";
import { CertManager } from "./cert-manager.secret";
import { CloudflareDDNS } from "./cloudflare-ddns.secret";
import { Ingress, IngressBackend, Service } from "cdk8s-plus-22";

const webServices: { [name: string]: WebServiceOptions } = {
  sonarr: {
    image: "linuxserver/sonarr",
    port: 8989,
    host: "sonarr.kliu.io",
    volumes: [
      {
        name: "config",
        path: "/config",
        size: Quantity.fromString("1Gi"),
      },
    ],
    hostPaths: [
      {
        name: "tv",
        containerPath: "/tv",
        hostPath: "/mnt/storage/Kevin/Videos/TV Shows",
      },
    ],
  },
  plex: {
    image: "linuxserver/plex",
    port: 32400,
    host: "plex.kliu.io",
    volumes: [
      {
        name: "config",
        path: "/config",
        size: Quantity.fromString("1Gi"),
      },
    ],
    hostPaths: [
      {
        name: "tv",
        containerPath: "/tv",
        hostPath: "/mnt/storage/Kevin/Videos/TV Shows",
      },
      {
        name: "movies",
        containerPath: "/movies",
        hostPath: "/mnt/storage/Kevin/Videos/Movies",
      },
    ],
    additionalOptions: {
      name: "plex",
      env: [
        {
          name: "PUID",
          value: "1000",
        },
        {
          name: "PGID",
          value: "100",
        },
      ],
    },
  },
};

export class Zero extends Chart {
  constructor(
    scope: Construct,
    id: string,
    props: ChartProps = {
      labels: {
        "io.kliu/prune-key": "cdk8s-zero",
      },
    }
  ) {
    super(scope, id, props);
    new CertManager(this, "cert-manager");
    new CloudflareDDNS(this, "cloudflare-ddns");

    const pt = new Service(this, "pterodactyl", {
      clusterIP: "None",
      ports: [{ port: 80 }],
    });
    new KubeEndpoints(this, "pterodactyl-endpoint", {
      metadata: {
        name: pt.name,
      },
      subsets: [
        {
          addresses: [{ ip: "192.168.1.16" }],
          ports: [{ port: 80 }],
        },
      ],
    });
    const ptNode = new Service(this, "pterodactyl-node", {
      clusterIP: "None",
      ports: [{ port: 80, targetPort: 8080 }],
    });
    new KubeEndpoints(this, "pt-node-endpoint", {
      metadata: {
        name: ptNode.name,
      },
      subsets: [
        {
          addresses: [{ ip: "192.168.1.16" }],
          ports: [{ port: 8080 }],
        },
      ],
    });
    new Ingress(this, `pterodactyl-ingress`, {
      metadata: {
        annotations: {
          "cert-manager.io/cluster-issuer":
            "cert-manager-letsencrypt-cluster-issuer",
          "kubernetes.io/ingress.class": "public",
        },
      },

      rules: [
        {
          host: "pt.kliu.io",
          path: "/",
          backend: IngressBackend.fromService(pt),
        },
      ],
      tls: [
        {
          hosts: ["pt.kliu.io"],
          secret: { name: `pterodactyl-ingress-tls` },
        },
      ],
    });
    new Ingress(this, `pterodactyl-node-ingress`, {
      metadata: {
        annotations: {
          "cert-manager.io/cluster-issuer":
            "cert-manager-letsencrypt-cluster-issuer",
          "kubernetes.io/ingress.class": "public",
        },
      },

      rules: [
        {
          host: "pt-node.kliu.io",
          path: "/",
          backend: IngressBackend.fromService(ptNode),
        },
      ],
      tls: [
        {
          hosts: ["pt-node.kliu.io"],
          secret: { name: `pterodactyl-node-ingress-tls` },
        },
      ],
    });

    for (const [name, opts] of Object.entries(webServices)) {
      new WebService(this, name, opts);
    }
  }
}

const app = new App();
new Zero(app, "zero");
app.synth();
