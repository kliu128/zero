import { Construct } from "constructs";
import { App, Chart, ChartProps } from "cdk8s";
import { WebService, WebServiceOptions } from "./web-service";
import { Quantity } from "cdk8s-plus-22/lib/imports/k8s";
import { CertManager } from "./cert-manager.secret";
import { MinecraftServer, MinecraftServerProps } from "./minecraft-server";

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

const minecraftServers: { [name: string]: MinecraftServerProps } = {
  "mc-test": {
    type: "VANILLA",
    version: "1.18.1",
    port: 25565,
    memory: 2048,
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

    for (const [name, opts] of Object.entries(webServices)) {
      new WebService(this, name, opts);
    }

    for (const [name, opts] of Object.entries(minecraftServers)) {
      new MinecraftServer(this, name, opts);
    }
  }
}

const app = new App();
new Zero(app, "zero");
app.synth();
