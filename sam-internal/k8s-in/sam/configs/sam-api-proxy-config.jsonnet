local configs = import "config.jsonnet";

std.prune({
  apiServerUrl: "localhost:8000",
  caFile: "/etc/pki_service/ca/cabundle.pem",
  certFile: "/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
  keyFile: "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
  enableValidators: true,
})
