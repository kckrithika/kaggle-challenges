local configs = import "config.jsonnet";

# Please check this config before merge using:
#
# ~/go/bin/manifestctl validate-config-maps --in ~/manifests/sam-internal/k8s-out/
#
# This will be automated soon

{
  disableCertsCheck: true,
  tnrpArchiveEndpoint: configs.tnrpArchiveEndpoint,
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
}
