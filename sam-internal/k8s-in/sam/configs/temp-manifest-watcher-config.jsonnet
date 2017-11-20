local configs = import "config.jsonnet";

{
  disableCertsCheck: true,
  tnrpArchiveEndpoint: "https://ops0-piperepo1-1-prd.eng.sfdc.net/tnrp/content_repo/0/archive/test-manifests",
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  lockName: "/locks/tempmanifestwatcher",
  crdEnabled: true,
  crdDeletionEnabled: true,
  endpointRepoName: configs.endpoint,
}
