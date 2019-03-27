local configs = import "config.jsonnet";

{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "switchboard-test",
    namespace: "service-mesh",
    labels: {
      app: "switchboard-test",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.pcnEnableLabel else {},
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
