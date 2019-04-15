local configs = import "config.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";
{
  apiVersion: "v1",
  kind: "Namespace",
  metadata: {
    name: versions.injectorNamespace,
    labels: {
          "sherpa-injector.service-mesh/inject": "disabled",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.pcnEnableLabel else {},
  },
}
