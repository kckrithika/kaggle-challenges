local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local utils = import "util_functions.jsonnet";
local funnelEndpointHost = std.split(configs.funnelVIP, ":")[0];
local funnelEndpointPort = std.split(configs.funnelVIP, ":")[1];

if configs.estate == "prd-sam" then
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
      - name: POD_NAME
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.name
      - name: POD_NAMESPACE
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.namespace
      - name: ELECTRON_OPA_CONFIG
        value: |
          <%-
          def env?(v) ENV.key?(v) and ENV[v].length > 0 end
          split_pod_name = ENV["POD_NAME"].split("-")
          metrics_scope = split_pod_name[0..(split_pod_name).length-3].join("-")
          metrics_scope += env?("POD_NAMESPACE") ? "." + ENV["POD_NAMESPACE"] : ""
          metrics_scope += ".' + configs.kingdom + '"
          -%>
          services:
            metrics:
              url: http://:9192
            electron:
              url: https://authz-svc-opa-lb.service-mesh.' + configs.estate + '.' + configs.kingdom + '.slb.sfdc.net:7442
              credentials:
                client_tls:
                  cert: /client-certs/client/certificates/client.pem
                  private_key: /client-certs/client/keys/client-key.pem
                  cacerts: /client-certs/ca/cacerts.pem
                  use_system_ca: true
          bundles:
            authz:
              resource: v1/authzpolicy
              service: electron
              polling:
                min_delay_seconds: 300
                max_delay_seconds: 360
          status:
            service: metrics
          decision_logs:
            service: metrics
            reporting:
              min_delay_seconds: 60
              max_delay_seconds: 60
          plugins:
            argus_metrics:
              enabled: true
              server_port: :9192
              funnel_url: http://' + funnelEndpointHost + '/
              metrics_scope: <%= metrics_scope -%>
      - name: ELECTRON_OPA_ISTIO_CONFIG
        value: |
          <%-
          def env?(v) ENV.key?(v) and ENV[v].length > 0 end
          split_pod_name = ENV["POD_NAME"].split("-")
          metrics_scope = split_pod_name[0..(split_pod_name).length-3].join("-")
          metrics_scope += env?("POD_NAMESPACE") ? "." + ENV["POD_NAMESPACE"] : ""
          metrics_scope += ".' + configs.kingdom + '"
          -%>
          services:
            metrics:
                url: http://:9192
            electron:
              url: https://authz-svc-opa-lb.service-mesh.' + configs.estate + '.' + configs.kingdom + '.slb.sfdc.net:7442
              credentials:
                client_tls:
                  cert: /client-certs/client/certificates/client.pem
                  private_key: /client-certs/client/keys/client-key.pem
                  cacerts: /client-certs/ca/cacerts.pem
                  use_system_ca: true
          bundles:
            authz:
              resource: v1/authzpolicy
              service: electron
              polling:
                min_delay_seconds: 300
                max_delay_seconds: 360
          status:
            service: metrics
          decision_logs:
            service: metrics
            reporting:
              min_delay_seconds: 60
              max_delay_seconds: 60
          plugins:
            envoy_ext_authz_grpc:
              addr: :9191
              query: data.authz.rules.proxy.x509.allow
              dry-run: false
              enable-reflection: false
            argus_metrics:
              enabled: true
              server_port: :9192
              funnel_url: http://' + funnelEndpointHost + '/
              metrics_scope: <%= metrics_scope -%>
    args:
      - echo -e "${ELECTRON_OPA_CONFIG}" > /templated-config/opa_config.yaml.erb &&
        /app/config_gen.rb -t /templated-config/opa_config.yaml.erb -o /generated-config/opa_config.yaml &&
        echo -e "${ELECTRON_OPA_ISTIO_CONFIG}" > /templated-config/opa_istio_config.yaml.erb &&
        /app/config_gen.rb -t /templated-config/opa_istio_config.yaml.erb -o /generated-config/opa_istio_config.yaml
    volumeMounts:
      - name: templated-config
        mountPath: /templated-config
      - name: generated-config
        mountPath: /generated-config
      - name: tls-client-cert
        mountPath: /client-certs
  - name: authz-config-init-sherpa
    image: ' + versions.configInitImage + '
    imagePullPolicy: IfNotPresent
    command: ["bash", "-c"]
    env:
      - name: POD_NAME
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.name
      - name: POD_NAMESPACE
        valueFrom:
          fieldRef:
            apiVersion: v1
            fieldPath: metadata.namespace
      - name: ELECTRON_OPA_CONFIG
        value: |
          <%-
          def env?(v) ENV.key?(v) and ENV[v].length > 0 end
          split_pod_name = ENV["POD_NAME"].split("-")
          metrics_scope = split_pod_name[0..(split_pod_name).length-3].join("-")
          metrics_scope += env?("POD_NAMESPACE") ? "." + ENV["POD_NAMESPACE"] : ""
          metrics_scope += ".' + configs.kingdom + '"
          -%>
          services:
            metrics:
                url: http://:9192
            electron:
              url: https://authz-svc-opa-lb.service-mesh.' + configs.estate + '.' + configs.kingdom + '.slb.sfdc.net:7442
              credentials:
                client_tls:
                  cert: /client-certs/client/certificates/client.pem
                  private_key: /client-certs/client/keys/client-key.pem
                  cacerts: /client-certs/ca/cacerts.pem
                  use_system_ca: true
          bundles:
            authz:
              resource: v1/authzpolicy
              service: electron
              polling:
                min_delay_seconds: 300
                max_delay_seconds: 360
          status:
            service: metrics
          decision_logs:
            service: metrics
            reporting:
              min_delay_seconds: 60
              max_delay_seconds: 60
          plugins:
            argus_metrics:
              enabled: true
              server_port: :9192
              funnel_url: http://' + funnelEndpointHost + '/
              metrics_scope: <%= metrics_scope -%>
      - name: ELECTRON_OPA_ISTIO_CONFIG
        value: |
          <%-
          def env?(v) ENV.key?(v) and ENV[v].length > 0 end
          split_pod_name = ENV["POD_NAME"].split("-")
          metrics_scope = split_pod_name[0..(split_pod_name).length-3].join("-")
          metrics_scope += env?("POD_NAMESPACE") ? "." + ENV["POD_NAMESPACE"] : ""
          metrics_scope += ".' + configs.kingdom + '"
          -%>
          services:
            metrics:
                url: http://:9192
            electron:
              url: https://authz-svc-opa-lb.service-mesh.' + configs.estate + '.' + configs.kingdom + '.slb.sfdc.net:7442
              credentials:
                client_tls:
                  cert: /client-certs/client/certificates/client.pem
                  private_key: /client-certs/client/keys/client-key.pem
                  cacerts: /client-certs/ca/cacerts.pem
                  use_system_ca: true
          bundles:
            authz:
              resource: v1/authzpolicy
              service: electron
              polling:
                min_delay_seconds: 300
                max_delay_seconds: 360
          status:
            service: metrics
          decision_logs:
            service: metrics
            reporting:
              min_delay_seconds: 60
              max_delay_seconds: 60
          plugins:
            envoy_ext_authz_grpc:
              addr: :9191
              query: data.authz.rules.proxy.x509.allow
              dry-run: false
              enable-reflection: false
            argus_metrics:
              enabled: true
              server_port: :9192
              funnel_url: http://' + funnelEndpointHost + '/
              metrics_scope: <%= metrics_scope -%>
    args:
      - echo -e "${ELECTRON_OPA_CONFIG}" > /templated-config/opa_config.yaml.erb &&
        /app/config_gen.rb -t /templated-config/opa_config.yaml.erb -o /generated-config/opa_config.yaml &&
        echo -e "${ELECTRON_OPA_ISTIO_CONFIG}" > /templated-config/opa_istio_config.yaml.erb &&
        /app/config_gen.rb -t /templated-config/opa_istio_config.yaml.erb -o /generated-config/opa_istio_config.yaml
    volumeMounts:
      - name: templated-config
        mountPath: /templated-config
      - name: generated-config
        mountPath: /generated-config
      - name: tls-client-cert
        mountPath: /client-certs
containers:
  - name: electron-opa
    image: ' + versions.devOpaImage + '
    imagePullPolicy: IfNotPresent
    args:
      - run
      - --server
      - --config-file=/config/opa_config.yaml
      - --log-level=debug
    securityContext:
      fsGroup: 7447
      runAsNonRoot: true
      runAsUser: 7447
    volumeMounts:
      - name: generated-config
        mountPath: /config
      - name: tls-client-cert
        mountPath: /client-certs
    livenessProbe:
      httpGet:
        path: /health?bundle=false
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health?bundle=true
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
  - name: electron-opa-istio
    image: ' + versions.devOpaIstioImage + '
    imagePullPolicy: IfNotPresent
    args:
      - run
      - --server
      - --config-file=/config/opa_istio_config.yaml
      - --log-level=debug
    securityContext:
      fsGroup: 7447
      runAsNonRoot: true
      runAsUser: 7447
    volumeMounts:
      - name: generated-config
        mountPath: /config
      - name: tls-client-cert
        mountPath: /client-certs
    livenessProbe:
      httpGet:
        path: /health?bundle=false
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
    readinessProbe:
      httpGet:
        path: /health?bundle=true
        scheme: HTTP
        port: 8181
      initialDelaySeconds: 5
      periodSeconds: 10
volumes:
  - name: templated-config
    emptyDir: {}
  - name: generated-config
    emptyDir: {}',
"mutationconfig.yaml":
'mutationConfigs:
  - name: "electron-opa-non-sherpa"
    annotationNamespace: "electron-opa.k8s-integration.sfdc.com"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init"]
    containers: ["electron-opa"]
    volumes: ["templated-config", "generated-config"]
    volumeMounts: []
    ignoreNamespaces: ["' + versions.injectorNamespace + '"]
    whitelistNamespaces: []
  - name: "electron-opa-istio-non-sherpa"
    annotationNamespace: "electron-opa-istio.k8s-integration.sfdc.com"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init"]
    containers: ["electron-opa-istio"]
    volumes: ["templated-config", "generated-config"]
    volumeMounts: []
    ignoreNamespaces: ["' + versions.injectorNamespace + '"]
    whitelistNamespaces: []
  - name: "electron-opa-sherpa"
    annotationNamespace: "electron-opa-sherpa.k8s-integration.sfdc.com"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init-sherpa"]
    containers: ["electron-opa"]
    volumes: ["templated-config", "generated-config"]
    volumeMounts: []
    ignoreNamespaces: ["' + versions.injectorNamespace + '"]
    whitelistNamespaces: []
  - name: "electron-opa-istio-sherpa"
    annotationNamespace: "electron-opa-istio-sherpa.k8s-integration.sfdc.com"
    annotationTrigger: "inject"
    initContainers: ["authz-config-init-sherpa"]
    containers: ["electron-opa-istio"]
    volumes: ["templated-config", "generated-config"]
    volumeMounts: []
    ignoreNamespaces: ["' + versions.injectorNamespace + '"]
    whitelistNamespaces: []'
  }
} else "SKIP"