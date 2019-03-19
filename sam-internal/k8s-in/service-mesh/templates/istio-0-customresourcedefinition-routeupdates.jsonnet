{
  apiVersion: "apiextensions.k8s.io/v1beta1",
  kind: "CustomResourceDefinition",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    labels: {
      app: "route-update-service",
    },
    name: "routeupdates.mesh.sfdc.net",
  },
  spec: {
    group: "mesh.sfdc.net",
    names: {
      categories: [
        "mesh-control-plane",
        "istio",
        "casam",
      ],
      kind: "RouteUpdate",
      listKind: "RouteUpdateList",
      plural: "routeupdates",
      singular: "routeupdate",
    },
    scope: "Namespaced",
    version: "v1",
  },
}
