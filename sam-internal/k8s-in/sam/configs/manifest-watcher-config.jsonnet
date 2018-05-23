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

  # [thargrove] Turning this to false because we went from ZIP 9999 to 1xxxx.  This should be switched back to true by 2018-05-24
  skipOldZips: false,
  etcdAppFolder: "manifest-watcher",
})
