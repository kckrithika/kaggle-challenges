{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "switchboard-test",
    namespace: "service-mesh",
  },
  spec: {
    type: "ExternalName",
    externalName: "switchboard-test-mvp-1.eng.sfdc.net",
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
