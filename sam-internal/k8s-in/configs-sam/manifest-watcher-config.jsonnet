local configs = import "config.jsonnet";

{
  disableCertsCheck: "true",
  tnrpArchiveEndpoint: configs.tnrpArchiveEndpoint,
  tlsEnabled: "true",
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  syntheticEndpoint: "http://$(WATCHDOG_SYNTHETIC_SERVICE_SERVICE_HOST):9090/tnrp/content_repo/0/archive",
}