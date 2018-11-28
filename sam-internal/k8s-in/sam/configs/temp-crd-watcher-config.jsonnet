local configs = import "config.jsonnet";

{
  disableCertsCheck: true,
  tnrpArchiveEndpoint: configs.tnrpArchiveEndpoint,
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  lockName: "/locks/tempmanifestwatcher",
  crdEnabled: true,
  crdDeletionEnabled: true,
  [if configs.estate != "prd-samdev" && configs.estate != "prd-samtest" && configs.estate != "prd-sam" then "endpointRepoName"]: "test-manifests",
  manifestV1Enabled: false,
  etcdAppFolder: "temp-crd-watcher",
  livenessProbePort: "21553",
  k4aEnabled: true,
}
