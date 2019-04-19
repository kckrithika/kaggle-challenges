local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "switchboard",
    namespace: "service-mesh",
    labels: {
      some_fake_label: "2",
      app: "switchboard",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  spec: {
    type: "ClusterIP",
    clusterIP: "None",
    ports: [
      {
        protocol: "TCP",
        port: 15001,
        targetPort: 15001,
      },
    ],
    # Reference the main Switchboard App
    selector: {
      sam_app: if configs.estate == "gsf-core-devmvp-sam2-sam" then "switchboard-mvp" else if configs.estate == "gsf-core-devmvp-sam2-samtest" then "switchboard-mvp-samtest" else "switchboard",
      sam_function: "switchboard",
    },
  },
}
