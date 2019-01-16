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
  manifestV1Enabled: false,
  etcdAppFolder: "temp-crd-watcher",
  livenessProbePort: "21553",
  k4aEnabled: true,
}
