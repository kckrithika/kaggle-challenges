local configs = import "config.jsonnet";

std.prune({
  disableCertsCheck: true,
  tnrpArchiveEndpoint: configs.tnrpArchiveEndpoint,
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  # This ensures we dont deploy an older zip than our previous one.  This can happen
  # with out-of-sync TNRP servers behind a VIP
  skipOldZips: true,
  etcdAppFolder: "manifest-watcher",
})
