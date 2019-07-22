{
  "apiVersion": "networking.istio.io/v1alpha3",
  "kind": "Sidecar",
  "metadata": {
    "name": "mesh-default",
    "namespace": "mesh-control-plane"
  },
  "spec": {
    "egress": [
      {
        "hosts": [
          // System namespaces
          "mesh-control-plane/*",
          "z9s-default/*",

          // App namespaces
          "app/*",
          "casam/*",
          "ccait/*",
          "core-on-sam-sp2/*",
          "emailinfra/*",
          "gater/*",
          "retail-cre/*",
          "retail-dfs/*",
          "retail-mds/*",
          "retail-rsui/*",
          "scone/*",
          "search-scale-safely/*",
          "service-mesh/*",
          "universal-search/*"
        ]
      }
    ]
  }
}
