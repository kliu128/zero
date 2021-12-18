import { Deployment, EnvValue, Secret } from "cdk8s-plus-22";
import { Construct } from "constructs";
import { config } from "./config.secret";

export class CloudflareDDNS extends Construct {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    const auth = new Secret(this, "secret");
    auth.addStringData("domain", "kliu.io");
    auth.addStringData("api", config.cloudflareDdnsApiKey);

    new Deployment(this, "deployment", {
      containers: [
        {
          image: "oznu/cloudflare-ddns",
          env: {
            ZONE: EnvValue.fromSecretValue({ secret: auth, key: "domain" }),
            API_KEY: EnvValue.fromSecretValue({ secret: auth, key: "api" }),
            SUBDOMAIN: EnvValue.fromValue("ext"),
          },
        },
      ],
    });
  }
}
