local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if electron_opa_utils.is_electron_opa_injector_test_cluster(configs.estate) then
{
apiVersion: "v1",
kind: "ConfigMap",
metadata: {
  name: "electron-opa-injector-configs-opa-istio-container",
  namespace: versions.injectorNamespace,
  labels: {
    app: "electron-opa-injector",
  } +
  // samlabelfilter.json requires this label to be present on GCP deployments
  if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
},
data: {
  "electron-opa-istio-container.yaml.template":
'containers:
  - name: electron-opa-istio
    image: {{ .Image }}
    {{- if .EnvironmentVars}}
    env:
    {{- range $key, $val := .EnvironmentVars}}
    - name: {{$key}}
      {{- if $val.FieldRefFieldPath}}
      valueFrom:
        fieldRef:
          apiVersion: {{$val.FieldRefApiVersion}}
          fieldPath: {{$val.FieldRefFieldPath}}
      {{- else}}
      value: "{{$val.Value}}"
      {{- end}}
    {{- end}}
    {{- end}}
    ports:
    - name: http
      containerPort: 8181
    livenessProbe:
      httpGet:
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 5
    readinessProbe:
      httpGet:
        path: /health?bundle=false
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 5
    terminationMessagePolicy: FallbackToLogsOnError',
},
} else "SKIP"
