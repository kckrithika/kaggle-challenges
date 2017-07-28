local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

{
  debug: true,
  dockerregistry: configs.registry,
  k8sapiserver: configs.k8sapiserver,
  tlsEnabled: true,
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  checkImageExistsFlag: true,
  httpsDisableCertsCheck: true,
  volPermissionInitContainerImage: samimages.permissionInitContainer,
}
