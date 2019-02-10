local configs = import "config.jsonnet";

{
  disableCertsCheck: true,
  tnrpArchiveEndpoint: configs.tnrpArchiveEndpoint,
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  lockName: "",
  crdEnabled: true,
  crdDeletionEnabled: true,
  manifestV1Enabled: false,
  etcdAppFolder: "",
  livenessProbePort: "21553",
  k4aEnabled: true,

  # This ensures we dont deploy an older zip than our previous one.  This can happen
  # with out-of-sync TNRP servers behind a VIP
  skipOldZips: true,

  deletionPercentageThreshold: 20,
}
