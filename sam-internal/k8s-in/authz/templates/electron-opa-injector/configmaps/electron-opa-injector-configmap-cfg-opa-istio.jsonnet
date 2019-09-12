local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

{
apiVersion: "v1",
kind: "ConfigMap",
metadata: {
  name: "electron-opa-injector-configs-opa-istio-config",
  namespace: versions.injectorNamespace,
  labels: {
    app: "electron-opa-injector",
  } +
  // samlabelfilter.json requires this label to be present on GCP deployments
  if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
},
data: {
  "config.yaml":
'services:
  - name: electron
    url: http://demo-authz-http.service-mesh.localhost.mesh.force.com:5442
    allow_insecure_tls: true
bundle:
  name: authzpolicy
  prefix: v1
  service: electron
  polling:
    min_delay_seconds: 300
    max_delay_seconds: 360
plugins:
  envoy_ext_authz_grpc:
    addr: :9191
    query: data.istio.authz.allow'
},
}
