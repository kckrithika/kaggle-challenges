local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if electron_opa_utils.is_electron_opa_injector_prod_cluster(configs.estate) then
{
apiVersion: "v1",
kind: "ConfigMap",
metadata: {
  name: "electron-opa-istio-sherpa-container",
  namespace: versions.injectorNamespace,
  labels: {
    app: "electron-opa-injector",
  } +
  // samlabelfilter.json requires this label to be present on GCP deployments
  if utils.is_pcn(configs.kingdom) then configs.pcnEnableLabel else {},
},
data: {
  "electron-opa-istio-container.yaml.template":
'initContainers:
   - name: authz-config-gen
     image: ops0-artifactrepo2-0-prd.data.sfdc.net/dva/collection-erb-config-gen:19
     imagePullPolicy: IfNotPresent
     command: ["bash", "-c"]
     env:
       - name: ELECTRON_OPA_ISTIO_CONFIG
         value: |
           services:
             electron:
               url: http://authz-svc-opa.service-mesh.localhost.mesh.force.com:5442
               allow_insecure_tls: true
               credentials:
                 client_tls:
                   cert: /client-certs/client/certificates/client.pem
                   private_key: /client-certs/client/keys/client-key.pem
           bundles:
             authz:
               resource: v1/authzpolicy
               service: electron
               polling:
                 min_delay_seconds: 300
                 max_delay_seconds: 360
           plugins:
             envoy_ext_authz_grpc:
               addr: :9191
               query: data.httpapi.authz.allow
               dry-run: false
               enable-reflection: false
     args:
       - echo -e "${ELECTRON_OPA_ISTIO_CONFIG}" > /config/opa_istio_config.yaml
     volumeMounts:
       - name: config
         mountPath: /config
containers:
  - name: electron-opa-istio
    image: {{ .Image }}
    args:
      - run
      - --server
      - --config-file=/config/opa_istio_config.yaml
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
    volumeMounts:
      - name: config
        mountPath: /config
      - name: tls-client-cert
        mountPath: /client-certs
    livenessProbe:
      httpGet:
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 3
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health?bundle=false
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 2
      periodSeconds: 10
    terminationMessagePolicy: FallbackToLogsOnError
volumes:
  - name: config
    emptyDir: {}',
},
} else "SKIP"
