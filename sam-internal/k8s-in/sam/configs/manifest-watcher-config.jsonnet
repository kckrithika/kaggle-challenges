local configs = import "config.jsonnet";

std.prune({
  disableCertsCheck: true,
  tnrpArchiveEndpoint: configs.tnrpArchiveEndpoint,
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  skipOldZips: (if configs.kingdom == "prd" then true),
})
