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
  crdDeletionEnabled: (if configs.estate != "prd-sam" then true else false),
  [if configs.estate != "prd-samdev" && configs.estate != "prd-samtest" then "endpointRepoName"]: "test-manifests",
  manifestV1Enabled: false,
  etcdAppFolder: "temp-crd-watcher",
  livenessProbePort: "21553",
}
