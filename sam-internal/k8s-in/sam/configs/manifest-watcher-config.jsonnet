local configs = import "config.jsonnet";

std.prune({
  disableCertsCheck: true,
  # [thargrove] Quick fix because 1-1 in this kingdom is returning stale latest.  TODO: Remove as soon as we have protection in manifest-watcher
  # from using an older zip
  tnrpArchiveEndpoint: (if configs.kingdom == "par" then "https://ops0-piperepo2-1-par.ops.sfdc.net/tnrp/content_repo/0/archive"
                        else if configs.kingdom == "prd" then "https://ops0-piperepo2-1-prd.eng.sfdc.net/tnrp/content_repo/0/archive"
                        else configs.tnrpArchiveEndpoint),
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  skipOldZips: (if configs.kingdom == "prd" then true),
})
