local configs = import "config.jsonnet";
local versions = import "service-mesh/sherpa-injector/versions.jsonnet";

{
apiVersion: "v1",
kind: "ConfigMap",
metadata: {
  name: "sherpa-injector-configs-data",
  namespace: versions.injectorNamespace,
  labels: {
    app: "sherpa-injector",
  } +
  // samlabelfilter.json requires this label to be present on GCP deployments
  if configs.estate == "gsf-core-devmvp-sam2-sam" then configs.pcnEnableLabel else {},
},
data: {
  "sherpa-container.yaml.template":
'containers:
  - name: sherpa
    image: {{ .SherpaImage }}
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
    # We are not restricting these ports for now. All ports are currently open and these settings are informational
    - name: h2-in
      containerPort: 7012
    - name: h1-in
      containerPort: 7014
    - name: h2-tls-in
      containerPort: 7443
    - name: h1-tls-in
      containerPort: 7442
    - name: admin
      containerPort: 15373
    volumeMounts:
    - mountPath: /client-certs
      name: "{{ .TlsClientCertName }}"
    - mountPath: /server-certs
      name: "{{ .TlsServerCertName }}"
    livenessProbe:
      exec:
        command:
        - ./bin/is-alive
      initialDelaySeconds: 20
      periodSeconds: 5
    readinessProbe:
      exec:
        command:
        - ./bin/is-ready
      initialDelaySeconds: 15
      periodSeconds: 5
    terminationMessagePolicy: FallbackToLogsOnError
',
},
}
