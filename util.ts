import { Secret } from "cdk8s-plus-22";
import { Construct } from "constructs";
import { EnvVar } from "./imports/k8s";

export function makeEnvObject(env: { [key: string]: string }): EnvVar[] {
  return Object.keys(env).map((key) => ({
    name: key,
    value: env[key],
  }));
}

export function secretFrom(
  scope: Construct,
  id: string,
  values: { [key: string]: string }
): Secret {
  const secret = new Secret(scope, id);
  Object.keys(values).forEach((key) => {
    secret.addStringData(key, values[key]);
  });
  return secret;
}
