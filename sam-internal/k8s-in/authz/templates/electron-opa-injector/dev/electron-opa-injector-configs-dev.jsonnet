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
"opencensus.yaml.erb":
"receivers:
  prometheus:
    config:
      global:
        scrape_interval: 60s
        scrape_timeout: 8s
      scrape_configs:
        - job_name: kubernetes-pods-0
          metrics_path: /metrics
          static_configs:
            - targets: ['localhost:17773']
              labels:
                _service: kubernetes-pods
                k8s_container_name: xauthz-opa-webhook
          metric_relabel_configs: []
exporters:
  funnel:
    host: <%= ENV['SFDC_METRICS_SERVICE_HOST'] %>
    port: <%= ENV['SFDC_METRICS_SERVICE_PORT'] %>
    enable_mtls: false
    gzip: true
    labels:
      k8s_pod_name: <%= ENV['FUNCTION_INSTANCE_NAME'] %>
      k8s_namespace: <%= ENV['NAMESPACE'] %>
      k8s_cluster: <%= ENV['ESTATE'] %>
      device: <%= ENV['FUNCTION_INSTANCE_NAME'] %>
      environment: <%= ENV['KINGDOM'] %>
zpages:
  port: 55679",
"sidecarconfig.yaml":
'initContainers:
  - name: authz-config-init
    image: ' + versions.configInitImage + '
    imagePullPolicy: IfNotPresent
    command: ["bash", "-c"]
    env:
      - name: ELECTRON_OPA_CONFIG
        value: |
          services:
            electron:
              url: https://authz-svc-opa.service-mesh.localhost.mesh.force.com:7442
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
      - name: ELECTRON_OPA_ISTIO_CONFIG
        value: |
          services:
            electron:
              url: https://authz-svc-opa.service-mesh.localhost.mesh.force.com:7442
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
      - echo -e "${ELECTRON_OPA_CONFIG}" > /config/opa_config.yaml &&
        echo -e "${ELECTRON_OPA_ISTIO_CONFIG}" > /config/opa_istio_config.yaml &&
        chmod -R 777 /client-certs/client
    volumeMounts:
      - name: config
        mountPath: /config
      - name: tls-client-cert
        mountPath: /client-certs
  - name: authz-config-init-sherpa
    image: ' + versions.configInitImage + '
    imagePullPolicy: IfNotPresent
    command: ["bash", "-c"]
    env:
      - name: ELECTRON_OPA_CONFIG
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
      - echo -e "${ELECTRON_OPA_CONFIG}" > /config/opa_config.yaml &&
        echo -e "${ELECTRON_OPA_ISTIO_CONFIG}" > /config/opa_istio_config.yaml &&
        chmod -R 777 /client-certs/client
    volumeMounts:
      - name: config
        mountPath: /config
      - name: tls-client-cert
        mountPath: /client-certs
containers:
  - name: electron-opa
    image: ' + versions.opaImage + '
    imagePullPolicy: IfNotPresent
    ports:
      - name: http
        containerPort: 8181
    args:
      - run
      - --server
      - --config-file=/config/opa_config.yaml
      - --log-level=debug
    volumeMounts:
      - name: config
        mountPath: /config
      - name: tls-client-cert
        mountPath: /client-certs
    livenessProbe:
      httpGet:
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health?bundle=false
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
  - name: electron-opa-istio
    image: ' + versions.opaIstioImage + '
    imagePullPolicy: IfNotPresent
    args:
      - run
      - --server
      - --config-file=/config/opa_istio_config.yaml
      - --log-level=debug
    volumeMounts:
      - name: config
        mountPath: /config
      - name: tls-client-cert
        mountPath: /client-certs
    livenessProbe:
      httpGet:
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health?bundle=false
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
volumes:
  - name: config
    emptyDir: {}',
"mutationconfig.yaml":
'mutationConfigs:
  - name: "electron-opa-non-sherpa"
    annotationNamespace: "electron-opa-injector.authz"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init"]
    containers: ["electron-opa"]
    volumes: ["config"]
    volumeMounts: []
    ignoreNamespaces: ["authz-injector"]
    whitelistNamespaces: []
  - name: "electron-opa-istio-non-sherpa"
    annotationNamespace: "electron-opa-istio-injector.authz"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init"]
    containers: ["electron-opa-istio"]
    volumes: ["config"]
    volumeMounts: []
    ignoreNamespaces: ["authz-injector"]
    whitelistNamespaces: []
  - name: "electron-opa-sherpa"
    annotationNamespace: "electron-opa-sherpa-injector.authz"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init-sherpa"]
    containers: ["electron-opa"]
    volumes: ["config"]
    volumeMounts: []
    ignoreNamespaces: ["authz-injector"]
    whitelistNamespaces: []
  - name: "electron-opa-istio-sherpa"
    annotationNamespace: "electron-opa-istio-sherpa-injector.authz"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init-sherpa"]
    containers: ["electron-opa-istio"]
    volumes: ["config"]
    volumeMounts: []
    ignoreNamespaces: ["authz-injector"]
    whitelistNamespaces: []'
  }
} else "SKIP"