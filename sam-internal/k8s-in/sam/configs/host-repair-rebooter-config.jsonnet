local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-sam" then
std.prune({
  crdNamespace: "sam-system",
  apiUrl: "https://gingham1-0-crz.data.sfdc.net/api",
  ginghamCertFile: "/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
  ginghamKeyFile: "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
  funnelEndpoint: configs.funnelVIP,
  gusCaseId: "a07B0000007rnzDIAQ",
}) else "SKIP"
