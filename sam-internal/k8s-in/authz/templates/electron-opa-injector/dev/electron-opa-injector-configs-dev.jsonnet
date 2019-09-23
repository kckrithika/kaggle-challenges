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
      env:
      - name: SFDC_ENVIRONMENT
        value: mesh
      - name: SETTINGS_SERVICENAME
        value: electron-opa
      - name: FUNCTION_NAMESPACE
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.namespace
      - name: FUNCTION_INSTANCE_NAME
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.name
      - name: FUNCTION_INSTANCE_IP
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: status.podIP
      - name: FUNCTION
        value: electron-opa
      - name: KINGDOM
        value: prd
      - name: ESTATE
        value: prd-samdev
      - name: SUPERPOD
        value: "-"
      - name: SETTINGS_SUPERPOD
        value: "-"
      - name: SETTINGS_PATH
        value: mesh.-.prd.-.electron-opa
      - name: SFDC_SETTINGS_PATH
        value: mesh.-.prd.-.electron-opa
      - name: SFDC_METRICS_SERVICE_HOST
        value: ajna0-funnel1-0-prd.data.sfdc.net
      - name: SFDC_METRICS_SERVICE_PORT
        value: "80"
    - name: electron-opa-istio
      image: ' + versions.opaIstioImage + '
      env:
      - name: SFDC_ENVIRONMENT
        value: mesh
      - name: SETTINGS_SERVICENAME
        value: electron-opa-istio
      - name: FUNCTION_NAMESPACE
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.namespace
      - name: FUNCTION_INSTANCE_NAME
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.name
      - name: FUNCTION_INSTANCE_IP
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: status.podIP
      - name: FUNCTION
        value: electron-opa-istio
      - name: KINGDOM
        value: prd
      - name: ESTATE
        value: prd-samdev
      - name: SUPERPOD
        value: "-"
      - name: SETTINGS_SUPERPOD
        value: "-"
      - name: SETTINGS_PATH
        value: mesh.-.prd.-.electron-opa-istio
      - name: SFDC_SETTINGS_PATH
        value: mesh.-.prd.-.electron-opa-istio
      - name: SFDC_METRICS_SERVICE_HOST
        value: ajna0-funnel1-0-prd.data.sfdc.net
      - name: SFDC_METRICS_SERVICE_PORT
        value: "80"',
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