local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if electron_opa_utils.is_electron_opa_injector_dev_cluster(configs.estate) then
{
  apiVersion: "v1",
  kind: "ConfigMap",
  metadata: {
    name: "electron-opa-injector-config",
    namespace: versions.injectorNamespace,
    labels: {
      app: "electron-opa-injector",
    } +
    // samlabelfilter.json requires this label to be present on GCP deployments
    if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
  },
  data: {
"sidecarconfig.yaml":
  'containers:
    - name: electron-opa
      image: ' + versions.opaImage + '
    - name: electron-opa-istio
      image: ' + versions.opaIstioImage,
"mutationconfig.yaml":
  'mutationConfigs:
    - name: "electron-opa"
      annotationNamespace: "electron-opa-injector.authz"
      annotationTrigger: "inject"
      initcontainers: []
      containers: ["electron-opa"]
      volumes: []
      volumeMounts: []
      ignoreNamespaces: []
      whitelistNamespaces: []
    - name: "electron-opa-istio"
      annotationNamespace: "electron-opa-istio-injector.authz"
      annotationTrigger: "inject"
      initcontainers: []
      containers: ["electron-opa-istio"]
      volumes: []
      volumeMounts: []
      ignoreNamespaces: []
      whitelistNamespaces: []'
  }
} else "SKIP"