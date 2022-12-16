import { Construct } from "constructs";
import { App, Chart, ChartProps } from "cdk8s";
import { WebService, WebServiceOptions } from "./web-service";
import { Quantity } from "cdk8s-plus-22/lib/imports/k8s";
import { CloudflareDDNS } from "./cloudflare-ddns";
import { ExternalService } from "./external-service";
import { Transmission } from "./transmission";
import { makeEnvObject } from "./util";

const webServices: { [name: string]: WebServiceOptions } = {
  sonarr: {
    image: "lscr.io/linuxserver/sonarr",
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
        hostPath: "/mnt/stor/Videos/TV Shows",
      },
      {
        name: "incoming",
        containerPath: "/data",
        hostPath: "/mnt/storage/Kevin/Incoming",
      },
    ],
    additionalOptions: {
      env: makeEnvObject({
        PUID: "0",
        PGID: "0",
      }),
    },
  },
  jackett: {
    image: "lscr.io/linuxserver/jackett",
    port: 9117,
    host: "jackett.kliu.io",
    volumes: [
      {
        name: "config",
        path: "/config",
        size: Quantity.fromString("1Gi"),
      },
    ],
  },
  radarr: {
    image: "lscr.io/linuxserver/radarr",
    port: 7878,
    host: "radarr.kliu.io",
    volumes: [
      {
        name: "config",
        path: "/config",
        size: Quantity.fromString("1Gi"),
      },
    ],
    hostPaths: [
      {
        name: "movies",
        containerPath: "/movies",
        hostPath: "/mnt/stor/Videos/Movies",
      },
      {
        name: "incoming",
        containerPath: "/data",
        hostPath: "/mnt/storage/Kevin/Incoming",
      },
    ],
    additionalOptions: {
      env: makeEnvObject({
        PUID: "0",
        PGID: "0",
      }),
    },
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
        hostPath: "/mnt/stor/Videos/TV Shows",
      },
      {
        name: "movies",
        containerPath: "/movies",
        hostPath: "/mnt/stor/Videos/Movies",
      },
    ],
    additionalOptions: {
      env: makeEnvObject({
        PUID: "1000",
        PGID: "100",
      }),
    },
  },
  bitwarden: {
    image: "vaultwarden/server:latest",
    port: 80,
    host: "pw.kliu.io",
    volumes: [
      {
        name: "data",
        path: "/data",
        size: Quantity.fromString("5Gi"),
      },
    ],
    additionalOptions: {
      env: makeEnvObject({
        DOMAIN: "https://pw.kliu.io",
        SIGNUPS_ALLOWED: "false",
      }),
    },
  },
  homeassistant: {
    image: "ghcr.io/home-assistant/home-assistant:stable",
    port: 8123,
    host: "home.kliu.io",
    volumes: [
      {
        name: "config",
        path: "/config",
        size: Quantity.fromString("5Gi"),
      },
    ],
    additionalPodOptions: {
      hostNetwork: true,
    },
    additionalOptions: {
      securityContext: {
        privileged: true,
      },
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
    new CloudflareDDNS(this, "cloudflare-ddns");
    new Transmission(this, "transmission");

    new ExternalService(this, "pterodactyl", {
      ip: "100.101.47.79",
      port: 80,
      host: "pt.kliu.io",
    });
    new ExternalService(this, "pterodactyl-node", {
      ip: "100.101.47.79", // tailscale
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
