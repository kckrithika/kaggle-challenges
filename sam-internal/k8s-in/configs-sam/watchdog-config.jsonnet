local configs = import "config.jsonnet";

{
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
}
