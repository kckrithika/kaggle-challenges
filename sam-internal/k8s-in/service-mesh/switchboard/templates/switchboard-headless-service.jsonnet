local configs = import "config.jsonnet";

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
    if configs.estate == "gsf-core-devmvp-sam2-sam" || configs.estate == "gsf-core-devmvp-sam2-samtest" then configs.pcnEnableLabel else {},
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
      sam_app: "switchboard-mvp",
      sam_function: "switchboard",
    },
  },
}
