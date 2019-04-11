local configs = import "config.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";

{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "sherpa-injector",
    namespace: versions.injectorNamespace,
    labels: {
      app: "sherpa-injector",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.pcnEnableLabel else {},
  },
  spec: {
    ports: [
      {
        name: "h1-tls-in-port",
        port: 17442,
        targetPort: 17442,
      },
    ],
    selector: {
      app: "sherpa-injector",
    },
  },
}
