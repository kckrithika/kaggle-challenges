local configs = import "config.jsonnet";
local sherpa_utils = import "service-mesh/sherpa-injector/sherpa_utils.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";

if sherpa_utils.is_sherpa_injector_dev_cluster(configs.estate) then
configs.deploymentBase("service-mesh") {
  metadata+: {
    name: "sherpa-injector-init",
    namespace: versions.injectorNamespace,
  },
  spec+: {
    // This is a HACK (fake deployment) to trick SAM/Packager to promote the Sherpa-Injector-Init image to production Artifactories
    replicas: 0,
    template: {
      metadata: {
        annotations+: {
          "sherpa-injector.service-mesh/inject": "disabled",
        },
        labels+: {
          name: "sherpa-injector-init",
        },
      },
      spec: {
        containers: [
          {
            name: "sherpa-injector-init",
            image: versions["1"].canarySherpaImage,
            imagePullPolicy: "IfNotPresent",
            resources: {
              requests: {
                cpu: "10m",
                memory: "64Mi",
              },
              limits: {
                cpu: "10m",
                memory: "64Mi",
              },
            },
          },
        ],
        nodeSelector: {
          pool: configs.estate,
        },
      },
    },
  },
}
else "SKIP"