import { Construct } from "constructs";
import { App, Chart, ChartProps } from "cdk8s";
import { WebService, WebServiceOptions } from "./web-service";
import { Quantity } from "cdk8s-plus-22/lib/imports/k8s";
import { CertManager } from "./cert-manager";
import { CloudflareDDNS } from "./cloudflare-ddns";
import { ExternalService } from "./external-service";
import { Transmission } from "./transmission";
import { makeEnvObject } from "./util";

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
      env: makeEnvObject({
        PUID: "1000",
        PGID: "100",
      }),
    },
  },
  "archiveteam-warrior": {
    image: "atdr.meo.ws/archiveteam/warrior-dockerfile",
    port: 8001,
    host: "warrior.kliu.io",
    volumes: [],
    additionalOptions: {
      env: makeEnvObject({
        DOWNLOADER: "kliu128",
        SELECTED_PROJECT: "auto",
      }),
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
    new Transmission(this, "transmission");

    new ExternalService(this, "pterodactyl", {
      ip: "192.168.1.16",
      port: 80,
      host: "pt.kliu.io",
    });
    new ExternalService(this, "pterodactyl-node", {
      ip: "192.168.1.16",
      port: 8080,
      host: "pt-node.kliu.io",
    });

    for (const [name, opts] of Object.entries(webServices)) {
      new WebService(this, name, opts);
    }
  }
}

const app = new App();
new Zero(app, "zero");
app.synth();
