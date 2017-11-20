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
  endpointRepoName: configs.endpoint,
}
