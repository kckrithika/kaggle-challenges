local configs = import "config.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";
if configs.kingdom == "prd" && configs.estate == "prd-samtest" then {

  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    name: versions.injectorNamespace,
    labels: {
          "sherpa-injector.service-mesh/inject": "disabled",
    },
  },
} else "SKIP"
