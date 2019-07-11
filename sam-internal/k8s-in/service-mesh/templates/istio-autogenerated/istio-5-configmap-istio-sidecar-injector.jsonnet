# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  data: {
    config: "policy: disabled\nalwaysInjectSelector:\nneverInjectSelector:\ntemplate: |-\n  rewriteAppHTTPProbe: {{ valueOrDefault .Values.sidecarInjectorWebhook.rewriteAppHTTPProbe false }}\n  {{- if or (not .Values.istio_cni.enabled) .Values.global.proxy.enableCoreDump }}\n  initContainers:\n  {{ if ne (annotation .ObjectMeta `sidecar.istio.io/interceptionMode` .ProxyConfig.InterceptionMode) `NONE` }}\n  {{- if not .Values.istio_cni.enabled }}\n  - name: istio-init\n  {{- if contains \"/\" .Values.global.proxy_init.image }}\n    image: \"{{ .Values.global.proxy_init.image }}\"\n  {{- else }}\n    image: \"{{ .Values.global.hub }}/{{ .Values.global.proxy_init.image }}:{{ .Values.global.tag }}\"\n  {{- end }}\n    args:\n    - \"-p\"\n    - \"15006\"\n    - \"-u\"\n    - 7447\n    - \"-m\"\n    - \"{{ annotation .ObjectMeta `sidecar.istio.io/interceptionMode` .ProxyConfig.InterceptionMode }}\"\n    - \"-i\"\n    - \"{{ annotation .ObjectMeta `traffic.sidecar.istio.io/includeOutboundIPRanges` .Values.global.proxy.includeIPRanges }}\"\n    - \"-x\"\n    - \"{{ annotation .ObjectMeta `traffic.sidecar.istio.io/excludeOutboundIPRanges` .Values.global.proxy.excludeIPRanges }}\"\n    - \"-b\"\n    - \"{{ annotation .ObjectMeta `traffic.sidecar.istio.io/includeInboundPorts` (includeInboundPorts .Spec.Containers) }}\"\n    - \"-d\"\n    - \"{{ excludeInboundPort (annotation .ObjectMeta `status.sidecar.istio.io/port` .Values.global.proxy.statusPort) (annotation .ObjectMeta `traffic.sidecar.istio.io/excludeInboundPorts` .Values.global.proxy.excludeInboundPorts) }}\"\n    {{ if or (isset .ObjectMeta.Annotations `traffic.sidecar.istio.io/excludeOutboundPorts`) (ne .Values.global.proxy.excludeOutboundPorts \"\") -}}\n    - \"-o\"\n    - \"{{ annotation .ObjectMeta `traffic.sidecar.istio.io/excludeOutboundPorts` .Values.global.proxy.excludeOutboundPorts }}\"\n    {{ end -}}\n    {{ if (isset .ObjectMeta.Annotations `traffic.sidecar.istio.io/kubevirtInterfaces`) -}}\n    - \"-k\"\n    - \"{{ index .ObjectMeta.Annotations `traffic.sidecar.istio.io/kubevirtInterfaces` }}\"\n    {{ end -}}\n    imagePullPolicy: \"{{ .Values.global.imagePullPolicy }}\"\n    resources:\n      requests:\n        cpu: 10m\n        memory: 10Mi\n      limits:\n        cpu: 100m\n        memory: 50Mi\n    securityContext:\n      runAsUser: 0\n      runAsNonRoot: false\n      capabilities:\n        add:\n        - NET_ADMIN\n      {{- if .Values.global.proxy.privileged }}\n      privileged: true\n      {{- end }}\n    restartPolicy: Always\n    env:\n    {{- if contains \"*\" (annotation .ObjectMeta `traffic.sidecar.istio.io/includeInboundPorts` \"\") }}\n    - name: INBOUND_CAPTURE_PORT\n      value: 15006\n    {{- end }}\n  {{- end }}\n  {{  end -}}\n  {{- if eq .Values.global.proxy.enableCoreDump true }}\n  - name: enable-core-dump\n    args:\n    - -c\n    - sysctl -w kernel.core_pattern=/var/lib/istio/core.proxy \u0026\u0026 ulimit -c unlimited\n    command:\n      - /bin/sh\n  {{- if contains \"/\" .Values.global.proxy_init.image }}\n    image: \"{{ .Values.global.proxy_init.image }}\"\n  {{- else }}\n    image: \"{{ .Values.global.hub }}/{{ .Values.global.proxy_init.image }}:{{ .Values.global.tag }}\"\n  {{- end }}\n    imagePullPolicy: IfNotPresent\n    resources: {}\n    securityContext:\n      runAsUser: 0\n      runAsNonRoot: false\n      privileged: true\n  {{ end }}\n  {{- end }}\n  containers:\n  - name: istio-proxy\n  {{- if contains \"/\" (annotation .ObjectMeta `sidecar.istio.io/proxyImage` .Values.global.proxy.image) }}\n    image: \"{{ annotation .ObjectMeta `sidecar.istio.io/proxyImage` .Values.global.proxy.image }}\"\n  {{- else }}\n    image: \"{{ annotation .ObjectMeta `sidecar.istio.io/proxyImage` .Values.global.hub }}/{{ .Values.global.proxy.image }}:{{ .Values.global.tag }}\"\n  {{- end }}\n    ports:\n    - containerPort: 15090\n      protocol: TCP\n      name: http-envoy-prom\n    args:\n    - proxy\n    - sidecar\n    - --domain\n    - $(POD_NAMESPACE).svc.{{ .Values.global.proxy.clusterDomain }}\n    - --configPath\n    - \"{{ .ProxyConfig.ConfigPath }}\"\n    - --binaryPath\n    - \"{{ .ProxyConfig.BinaryPath }}\"\n    - --serviceCluster\n    {{ if ne \"\" (index .ObjectMeta.Labels \"app\") -}}\n    - \"{{ index .ObjectMeta.Labels `app` }}.$(POD_NAMESPACE)\"\n    {{ else -}}\n    - \"{{ valueOrDefault .DeploymentMeta.Name `istio-proxy` }}.{{ valueOrDefault .DeploymentMeta.Namespace `default` }}\"\n    {{ end -}}\n    - --drainDuration\n    - \"{{ formatDuration .ProxyConfig.DrainDuration }}\"\n    - --parentShutdownDuration\n    - \"{{ formatDuration .ProxyConfig.ParentShutdownDuration }}\"\n    - --discoveryAddress\n    - \"{{ annotation .ObjectMeta `sidecar.istio.io/discoveryAddress` .ProxyConfig.DiscoveryAddress }}\"\n  {{- if eq .Values.global.proxy.tracer \"lightstep\" }}\n    - --lightstepAddress\n    - \"{{ .ProxyConfig.GetTracing.GetLightstep.GetAddress }}\"\n    - --lightstepAccessToken\n    - \"{{ .ProxyConfig.GetTracing.GetLightstep.GetAccessToken }}\"\n    - --lightstepSecure={{ .ProxyConfig.GetTracing.GetLightstep.GetSecure }}\n    - --lightstepCacertPath\n    - \"{{ .ProxyConfig.GetTracing.GetLightstep.GetCacertPath }}\"\n  {{- else if eq .Values.global.proxy.tracer \"zipkin\" }}\n    - --zipkinAddress\n    - \"{{ .ProxyConfig.GetTracing.GetZipkin.GetAddress }}\"\n  {{- else if eq .Values.global.proxy.tracer \"datadog\" }}\n    - --datadogAgentAddress\n    - \"{{ .ProxyConfig.GetTracing.GetDatadog.GetAddress }}\"\n  {{- end }}\n  {{- if .Values.global.proxy.logLevel }}\n    - --proxyLogLevel={{ .Values.global.proxy.logLevel }}\n  {{- end}}\n  {{- if .Values.global.proxy.componentLogLevel }}\n    - --proxyComponentLogLevel={{ .Values.global.proxy.componentLogLevel }}\n  {{- end}}\n    - --dnsRefreshRate\n    - {{ .Values.global.proxy.dnsRefreshRate }}\n    - --connectTimeout\n    - \"{{ formatDuration .ProxyConfig.ConnectTimeout }}\"\n  {{- if .Values.global.proxy.envoyStatsd.enabled }}\n    - --statsdUdpAddress\n    - \"{{ .ProxyConfig.StatsdUdpAddress }}\"\n  {{- end }}\n  {{- if .Values.global.proxy.envoyMetricsService.enabled }}\n    - --envoyMetricsServiceAddress\n    - \"{{ .ProxyConfig.EnvoyMetricsServiceAddress }}\"\n  {{- end }}\n    - --proxyAdminPort\n    - \"{{ .ProxyConfig.ProxyAdminPort }}\"\n    {{ if gt .ProxyConfig.Concurrency 0 -}}\n    - --concurrency\n    - \"{{ .ProxyConfig.Concurrency }}\"\n    {{ end -}}\n    - --controlPlaneAuthPolicy\n    - \"{{ annotation .ObjectMeta `sidecar.istio.io/controlPlaneAuthPolicy` .ProxyConfig.ControlPlaneAuthPolicy }}\"\n  {{- if (ne (annotation .ObjectMeta \"status.sidecar.istio.io/port\" .Values.global.proxy.statusPort) \"0\") }}\n    - --statusPort\n    - \"{{ annotation .ObjectMeta `status.sidecar.istio.io/port` .Values.global.proxy.statusPort }}\"\n    - --applicationPorts\n    - \"{{ annotation .ObjectMeta `readiness.status.sidecar.istio.io/applicationPorts` (applicationPorts .Spec.Containers) }}\"\n  {{- end }}\n  {{- if .Values.global.trustDomain }}\n    - --trust-domain={{ .Values.global.trustDomain }}\n  {{- end }}\n    env:\n    - name: POD_NAME\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.name\n    - name: POD_NAMESPACE\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.namespace\n    - name: INSTANCE_IP\n      valueFrom:\n        fieldRef:\n          fieldPath: status.podIP\n  {{ if eq .Values.global.proxy.tracer \"datadog\" }}\n    - name: HOST_IP\n      valueFrom:\n        fieldRef:\n          fieldPath: status.hostIP\n  {{ end }}\n    - name: ISTIO_META_POD_NAME\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.name\n    - name: ISTIO_META_CONFIG_NAMESPACE\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.namespace\n    - name: ISTIO_META_INTERCEPTION_MODE\n      value: \"{{ or (index .ObjectMeta.Annotations `sidecar.istio.io/interceptionMode`) .ProxyConfig.InterceptionMode.String }}\"\n    - name: ISTIO_META_INCLUDE_INBOUND_PORTS\n      value: \"{{ annotation .ObjectMeta `traffic.sidecar.istio.io/includeInboundPorts` (applicationPorts .Spec.Containers) }}\"\n    {{- if .Values.global.network }}\n    - name: ISTIO_META_NETWORK\n      value: \"{{ .Values.global.network }}\"\n    {{- end }}\n    {{ if .ObjectMeta.Annotations }}\n    - name: ISTIO_METAJSON_ANNOTATIONS\n      value: |\n             {{ toJSON .ObjectMeta.Annotations }}\n    {{ end }}\n    {{ if .ObjectMeta.Labels }}\n    - name: ISTIO_METAJSON_LABELS\n      value: |\n             {{ toJSON .ObjectMeta.Labels }}\n    {{ end }}\n    {{- if (isset .ObjectMeta.Annotations `sidecar.istio.io/bootstrapOverride`) }}\n    - name: ISTIO_BOOTSTRAP_OVERRIDE\n      value: \"/etc/istio/custom-bootstrap/custom_bootstrap.json\"\n    {{- end }}\n    {{- if .Values.global.sds.customTokenDirectory }}\n    - name: ISTIO_META_SDS_TOKEN_PATH\n      value: \"{{ .Values.global.sds.customTokenDirectory -}}/sdstoken\"\n    {{- end }}\n    ###\n    # Start metadata fields used by switchboard for building metric tags.\n    ###\n    - name: ISTIO_META_hostname\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.name\n    - name: ISTIO_META_namespace\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.namespace\n    ###\n    # End metadata fields used by switchboard for building metric tags.\n    ###\n    ###\n    # Start metadata fields for configuring sidecar metrics.\n    ###\n    # We currently want to include all envoy metrics, so the inclusion list includes all known prefixes.\n    - name: ISTIO_METAJSON_METRICS_INCLUSIONS\n      value: \"{\\\"sidecar.istio.io/statsInclusionPrefixes\\\": \\\"access_log_file,cluster,cluster_manager,control_plane,http,http2,http_mixer_filter,listener,listener_manager,redis,runtime,server,stats,tcp,tcp_mixer_filter,tracing\\\"}\"\n    ###\n    # End metadata fields for configuring sidecar metrics.\n    ###\n    imagePullPolicy: {{ .Values.global.imagePullPolicy }}\n    {{ if ne (annotation .ObjectMeta `status.sidecar.istio.io/port` .Values.global.proxy.statusPort) `0` }}\n    readinessProbe:\n      httpGet:\n        path: /healthz/ready\n        port: {{ annotation .ObjectMeta `status.sidecar.istio.io/port` .Values.global.proxy.statusPort }}\n      initialDelaySeconds: {{ annotation .ObjectMeta `readiness.status.sidecar.istio.io/initialDelaySeconds` .Values.global.proxy.readinessInitialDelaySeconds }}\n      periodSeconds: {{ annotation .ObjectMeta `readiness.status.sidecar.istio.io/periodSeconds` .Values.global.proxy.readinessPeriodSeconds }}\n      failureThreshold: {{ annotation .ObjectMeta `readiness.status.sidecar.istio.io/failureThreshold` .Values.global.proxy.readinessFailureThreshold }}\n    {{ end -}}\n    securityContext:\n      {{- if .Values.global.proxy.privileged }}\n      privileged: true\n      {{- end }}\n      {{- if ne .Values.global.proxy.enableCoreDump true }}\n      readOnlyRootFilesystem: true\n      {{- end }}\n      {{ if eq (annotation .ObjectMeta `sidecar.istio.io/interceptionMode` .ProxyConfig.InterceptionMode) `TPROXY` -}}\n      capabilities:\n        add:\n        - NET_ADMIN\n      runAsGroup: 7447\n      {{ else -}}\n      {{ if and .Values.global.sds.enabled .Values.global.sds.useTrustworthyJwt }}\n      runAsGroup: 7447\n      {{- end }}\n      runAsUser: 7447\n      {{- end }}\n    resources:\n      {{ if or (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPU`) (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemory`) -}}\n      requests:\n        {{ if (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyCPU`) -}}\n        cpu: \"{{ index .ObjectMeta.Annotations `sidecar.istio.io/proxyCPU` }}\"\n        {{ end}}\n        {{ if (isset .ObjectMeta.Annotations `sidecar.istio.io/proxyMemory`) -}}\n        memory: \"{{ index .ObjectMeta.Annotations `sidecar.istio.io/proxyMemory` }}\"\n        {{ end }}\n    {{ else -}}\n  {{- if .Values.global.proxy.resources }}\n      {{ toYaml .Values.global.proxy.resources | indent 4 }}\n  {{- end }}\n    {{  end -}}\n    volumeMounts:\n    {{ if (isset .ObjectMeta.Annotations `sidecar.istio.io/bootstrapOverride`) }}\n    - mountPath: /etc/istio/custom-bootstrap\n      name: custom-bootstrap-volume\n    {{- end }}\n    - mountPath: /etc/istio/proxy\n      name: istio-envoy\n    {{- if .Values.global.sds.enabled }}\n    - mountPath: /var/run/sds/uds_path\n      name: sds-uds-path\n      readOnly: true\n    {{- if .Values.global.sds.useTrustworthyJwt }}\n    - mountPath: /var/run/secrets/tokens\n      name: istio-token\n    {{- end }}\n    {{- if .Values.global.sds.customTokenDirectory }}\n    - mountPath: \"{{ .Values.global.sds.customTokenDirectory -}}\"\n      name: custom-sds-token\n      readOnly: true\n    {{- end }}\n    {{- else }}\n    - mountPath: /etc/certs/root-cert.pem # Maddog certs mapped to istio certs default locations.\n      name: tls-server-cert               # Volume should be defined in Manifest file.\n      subPath: ca.pem\n    - mountPath: /etc/certs/cert-chain.pem\n      name: tls-server-cert\n      subPath: server/certificates/server.pem\n    - mountPath: /etc/certs/key.pem\n      name: tls-server-cert\n      subPath: server/keys/server-key.pem\n    - mountPath: /etc/certs/client.pem\n      name: tls-client-cert\n      subPath: client/certificates/client.pem\n    - mountPath: /etc/certs/client-key.pem\n      name: tls-client-cert\n      subPath: client/keys/client-key.pem\n    {{- end }}\n    {{- if and (eq .Values.global.proxy.tracer \"lightstep\") .Values.global.tracer.lightstep.cacertPath }}\n    - mountPath: {{ directory .ProxyConfig.GetTracing.GetLightstep.GetCacertPath }}\n      name: lightstep-certs\n      readOnly: true\n    {{- end }}\n      {{- if isset .ObjectMeta.Annotations `sidecar.istio.io/userVolumeMount` }}\n      {{ range $index, $value := fromJSON (index .ObjectMeta.Annotations `sidecar.istio.io/userVolumeMount`) }}\n    - name: \"{{  $index }}\"\n      {{ toYaml $value | indent 4 }}\n      {{ end }}\n      {{- end }}\n  volumes:\n  {{- if (isset .ObjectMeta.Annotations `sidecar.istio.io/bootstrapOverride`) }}\n  - name: custom-bootstrap-volume\n    configMap:\n      name: {{ annotation .ObjectMeta `sidecar.istio.io/bootstrapOverride` \"\" }}\n  {{- end }}\n  - emptyDir:\n      medium: Memory\n    name: istio-envoy\n  {{- if .Values.global.sds.enabled }}\n  - name: sds-uds-path\n    hostPath:\n      path: /var/run/sds/uds_path\n      type: Socket\n  {{- if .Values.global.sds.customTokenDirectory }}\n  - name: custom-sds-token\n    secret:\n      secretName: sdstokensecret\n  {{- end }}\n  {{- if .Values.global.sds.useTrustworthyJwt }}\n  - name: istio-token\n    projected:\n      sources:\n      - serviceAccountToken:\n          path: istio-token\n          expirationSeconds: 43200\n          audience: {{ .Values.global.trustDomain }}\n  {{- end }}\n  {{- else }}\n    {{- if isset .ObjectMeta.Annotations `sidecar.istio.io/userVolume` }}\n    {{range $index, $value := fromJSON (index .ObjectMeta.Annotations `sidecar.istio.io/userVolume`) }}\n  - name: \"{{ $index }}\"\n    {{ toYaml $value | indent 2 }}\n    {{ end }}\n    {{ end }}\n  {{- end }}\n  {{- if and (eq .Values.global.proxy.tracer \"lightstep\") .Values.global.tracer.lightstep.cacertPath }}\n  - name: lightstep-certs\n    secret:\n      optional: true\n      secretName: lightstep.cacert\n  {{- end }}\n  {{- if .Values.global.podDNSSearchNamespaces }}\n  dnsConfig:\n    searches:\n      {{- range .Values.global.podDNSSearchNamespaces }}\n      - {{ render . }}\n      {{- end }}\n  {{- end }}",
    values: "{\"certmanager\":{\"enabled\":false},\"galley\":{\"enabled\":false},\"gateways\":{\"enabled\":true,\"global\":{\"arch\":{\"amd64\":2,\"ppc64le\":2,\"s390x\":2},\"configValidation\":false,\"controlPlaneSecurityEnabled\":false,\"defaultNodeSelector\":{},\"defaultPodDisruptionBudget\":{\"enabled\":false},\"defaultResources\":{\"requests\":{\"cpu\":\"10m\"}},\"defaultTolerations\":[],\"disablePolicyChecks\":true,\"enableHelmTest\":false,\"enableTracing\":false,\"hub\":\"ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging\",\"imagePullPolicy\":\"IfNotPresent\",\"imagePullSecrets\":null,\"k8sIngress\":{\"enableHttps\":false,\"enabled\":false,\"gatewayName\":\"ingressgateway\"},\"localityLbSetting\":{},\"logging\":{\"level\":\"default:info\"},\"meshExpansion\":{\"enabled\":false,\"useILB\":false},\"meshNetworks\":{},\"monitoringPort\":15014,\"mtls\":{\"enabled\":false},\"multiCluster\":{\"enabled\":false},\"oneNamespace\":false,\"outboundTrafficPolicy\":{\"mode\":\"ALLOW_ANY\"},\"policyCheckFailOpen\":false,\"priorityClassName\":\"\",\"proxy\":{\"accessLogEncoding\":\"TEXT\",\"accessLogFile\":\"\",\"accessLogFormat\":\"\",\"autoInject\":\"enabled\",\"clusterDomain\":\"cluster.local\",\"componentLogLevel\":\"\",\"concurrency\":2,\"dnsRefreshRate\":\"300s\",\"enableCoreDump\":false,\"envoyMetricsService\":{\"enabled\":true,\"host\":\"switchboard.service-mesh\",\"port\":15001},\"envoyStatsd\":{\"enabled\":false,\"host\":null,\"port\":null},\"excludeIPRanges\":\"\",\"excludeInboundPorts\":\"\",\"excludeOutboundPorts\":\"\",\"image\":\"proxy\",\"includeIPRanges\":\"127.1.2.3/32\",\"includeInboundPorts\":\"*\",\"kubevirtInterfaces\":\"\",\"logLevel\":\"info\",\"privileged\":false,\"readinessFailureThreshold\":30,\"readinessInitialDelaySeconds\":1,\"readinessPeriodSeconds\":2,\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"1024Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}},\"statusPort\":15020,\"tracer\":\"zipkin\"},\"proxy_init\":{\"image\":\"proxy_init\"},\"sds\":{\"enabled\":false,\"udsPath\":\"\",\"useNormalJwt\":false,\"useTrustworthyJwt\":false},\"tag\":\"f4b0db053ed277ba5335e7c2e88e505445b4ac92\",\"tracer\":{\"datadog\":{\"address\":\"$(HOST_IP):8126\"},\"lightstep\":{\"accessToken\":\"\",\"address\":\"\",\"cacertPath\":\"\",\"secure\":true},\"zipkin\":{\"address\":\"\"}},\"trustDomain\":\"\",\"useMCP\":false},\"istio-egressgateway\":{\"autoscaleEnabled\":true,\"autoscaleMax\":5,\"autoscaleMin\":1,\"cpu\":{\"targetAverageUtilization\":80},\"enabled\":false,\"env\":{\"ISTIO_META_ROUTER_MODE\":\"sni-dnat\"},\"labels\":{\"app\":\"istio-egressgateway\",\"istio\":\"egressgateway\"},\"nodeSelector\":{},\"podAnnotations\":{},\"podAntiAffinityLabelSelector\":[],\"podAntiAffinityTermLabelSelector\":[],\"ports\":[{\"name\":\"http2\",\"port\":80},{\"name\":\"https\",\"port\":443},{\"name\":\"tls\",\"port\":15443,\"targetPort\":15443}],\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"256Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}},\"secretVolumes\":[{\"mountPath\":\"/etc/istio/egressgateway-certs\",\"name\":\"egressgateway-certs\",\"secretName\":\"istio-egressgateway-certs\"},{\"mountPath\":\"/etc/istio/egressgateway-ca-certs\",\"name\":\"egressgateway-ca-certs\",\"secretName\":\"istio-egressgateway-ca-certs\"}],\"serviceAnnotations\":{},\"tolerations\":[],\"type\":\"ClusterIP\"},\"istio-ilbgateway\":{\"autoscaleEnabled\":true,\"autoscaleMax\":5,\"autoscaleMin\":1,\"cpu\":{\"targetAverageUtilization\":80},\"enabled\":false,\"labels\":{\"app\":\"istio-ilbgateway\",\"istio\":\"ilbgateway\"},\"loadBalancerIP\":\"\",\"nodeSelector\":{},\"podAnnotations\":{},\"ports\":[{\"name\":\"grpc-pilot-mtls\",\"port\":15011},{\"name\":\"grpc-pilot\",\"port\":15010},{\"name\":\"tcp-citadel-grpc-tls\",\"port\":8060,\"targetPort\":8060},{\"name\":\"tcp-dns\",\"port\":5353}],\"resources\":{\"requests\":{\"cpu\":\"800m\",\"memory\":\"512Mi\"}},\"secretVolumes\":[{\"mountPath\":\"/etc/istio/ilbgateway-certs\",\"name\":\"ilbgateway-certs\",\"secretName\":\"istio-ilbgateway-certs\"},{\"mountPath\":\"/etc/istio/ilbgateway-ca-certs\",\"name\":\"ilbgateway-ca-certs\",\"secretName\":\"istio-ilbgateway-ca-certs\"}],\"serviceAnnotations\":{\"cloud.google.com/load-balancer-type\":\"internal\"},\"tolerations\":[],\"type\":\"LoadBalancer\"},\"istio-ingressgateway\":{\"applicationPorts\":\"\",\"autoscaleEnabled\":true,\"autoscaleMax\":5,\"autoscaleMin\":1,\"cpu\":{\"targetAverageUtilization\":80},\"enabled\":true,\"env\":{\"ISTIO_META_ROUTER_MODE\":\"sni-dnat\"},\"externalIPs\":[],\"labels\":{\"app\":\"istio-ingressgateway\",\"istio\":\"ingressgateway\"},\"loadBalancerIP\":\"\",\"loadBalancerSourceRanges\":[],\"meshExpansionPorts\":[{\"name\":\"tcp-pilot-grpc-tls\",\"port\":15011,\"targetPort\":15011},{\"name\":\"tcp-mixer-grpc-tls\",\"port\":15004,\"targetPort\":15004},{\"name\":\"tcp-citadel-grpc-tls\",\"port\":8060,\"targetPort\":8060},{\"name\":\"tcp-dns-tls\",\"port\":853,\"targetPort\":853}],\"nodeSelector\":{},\"podAnnotations\":{},\"podAntiAffinityLabelSelector\":[],\"podAntiAffinityTermLabelSelector\":[],\"ports\":[{\"name\":\"status-port\",\"port\":15020,\"targetPort\":15020},{\"name\":\"http2\",\"nodePort\":31380,\"port\":80,\"targetPort\":80},{\"name\":\"https\",\"nodePort\":31390,\"port\":443},{\"name\":\"tcp\",\"nodePort\":31400,\"port\":31400},{\"name\":\"https-kiali\",\"port\":15029,\"targetPort\":15029},{\"name\":\"https-prometheus\",\"port\":15030,\"targetPort\":15030},{\"name\":\"https-grafana\",\"port\":15031,\"targetPort\":15031},{\"name\":\"https-tracing\",\"port\":15032,\"targetPort\":15032},{\"name\":\"tls\",\"port\":15443,\"targetPort\":15443}],\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"1024Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}},\"sds\":{\"enabled\":false,\"image\":\"node-agent-k8s\",\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"1024Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}}},\"secretVolumes\":[{\"mountPath\":\"/etc/istio/ingressgateway-certs\",\"name\":\"ingressgateway-certs\",\"secretName\":\"istio-ingressgateway-certs\"},{\"mountPath\":\"/etc/istio/ingressgateway-ca-certs\",\"name\":\"ingressgateway-ca-certs\",\"secretName\":\"istio-ingressgateway-ca-certs\"}],\"serviceAnnotations\":{},\"tolerations\":[],\"type\":\"LoadBalancer\"}},\"global\":{\"arch\":{\"amd64\":2,\"ppc64le\":2,\"s390x\":2},\"configValidation\":false,\"controlPlaneSecurityEnabled\":false,\"defaultNodeSelector\":{},\"defaultPodDisruptionBudget\":{\"enabled\":false},\"defaultResources\":{\"requests\":{\"cpu\":\"10m\"}},\"defaultTolerations\":[],\"disablePolicyChecks\":true,\"enableHelmTest\":false,\"enableTracing\":false,\"hub\":\"ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging\",\"imagePullPolicy\":\"IfNotPresent\",\"imagePullSecrets\":null,\"k8sIngress\":{\"enableHttps\":false,\"enabled\":false,\"gatewayName\":\"ingressgateway\"},\"localityLbSetting\":{},\"logging\":{\"level\":\"default:info\"},\"meshExpansion\":{\"enabled\":false,\"useILB\":false},\"meshNetworks\":{},\"monitoringPort\":15014,\"mtls\":{\"enabled\":false},\"multiCluster\":{\"enabled\":false},\"oneNamespace\":false,\"outboundTrafficPolicy\":{\"mode\":\"ALLOW_ANY\"},\"policyCheckFailOpen\":false,\"priorityClassName\":\"\",\"proxy\":{\"accessLogEncoding\":\"TEXT\",\"accessLogFile\":\"\",\"accessLogFormat\":\"\",\"autoInject\":\"enabled\",\"clusterDomain\":\"cluster.local\",\"componentLogLevel\":\"\",\"concurrency\":2,\"dnsRefreshRate\":\"300s\",\"enableCoreDump\":false,\"envoyMetricsService\":{\"enabled\":true,\"host\":\"switchboard.service-mesh\",\"port\":15001},\"envoyStatsd\":{\"enabled\":false,\"host\":null,\"port\":null},\"excludeIPRanges\":\"\",\"excludeInboundPorts\":\"\",\"excludeOutboundPorts\":\"\",\"image\":\"proxy\",\"includeIPRanges\":\"127.1.2.3/32\",\"includeInboundPorts\":\"*\",\"kubevirtInterfaces\":\"\",\"logLevel\":\"info\",\"privileged\":false,\"readinessFailureThreshold\":30,\"readinessInitialDelaySeconds\":1,\"readinessPeriodSeconds\":2,\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"1024Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}},\"statusPort\":15020,\"tracer\":\"zipkin\"},\"proxy_init\":{\"image\":\"proxy_init\"},\"sds\":{\"enabled\":false,\"udsPath\":\"\",\"useNormalJwt\":false,\"useTrustworthyJwt\":false},\"tag\":\"f4b0db053ed277ba5335e7c2e88e505445b4ac92\",\"tracer\":{\"datadog\":{\"address\":\"$(HOST_IP):8126\"},\"lightstep\":{\"accessToken\":\"\",\"address\":\"\",\"cacertPath\":\"\",\"secure\":true},\"zipkin\":{\"address\":\"\"}},\"trustDomain\":\"\",\"useMCP\":false},\"grafana\":{\"enabled\":false},\"istio_cni\":{\"enabled\":false},\"istiocoredns\":{\"enabled\":false},\"kiali\":{\"enabled\":false},\"mixer\":{\"adapters\":{\"kubernetesenv\":{\"enabled\":true},\"prometheus\":{\"enabled\":true,\"metricsExpiryDuration\":\"10m\"},\"stdio\":{\"enabled\":false,\"outputAsJson\":true},\"useAdapterCRDs\":false},\"enabled\":false,\"env\":{\"GODEBUG\":\"gctrace=1\",\"GOMAXPROCS\":\"6\"},\"global\":{\"arch\":{\"amd64\":2,\"ppc64le\":2,\"s390x\":2},\"configValidation\":false,\"controlPlaneSecurityEnabled\":false,\"defaultNodeSelector\":{},\"defaultPodDisruptionBudget\":{\"enabled\":false},\"defaultResources\":{\"requests\":{\"cpu\":\"10m\"}},\"defaultTolerations\":[],\"disablePolicyChecks\":true,\"enableHelmTest\":false,\"enableTracing\":false,\"hub\":\"ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging\",\"imagePullPolicy\":\"IfNotPresent\",\"imagePullSecrets\":null,\"k8sIngress\":{\"enableHttps\":false,\"enabled\":false,\"gatewayName\":\"ingressgateway\"},\"localityLbSetting\":{},\"logging\":{\"level\":\"default:info\"},\"meshExpansion\":{\"enabled\":false,\"useILB\":false},\"meshNetworks\":{},\"monitoringPort\":15014,\"mtls\":{\"enabled\":false},\"multiCluster\":{\"enabled\":false},\"oneNamespace\":false,\"outboundTrafficPolicy\":{\"mode\":\"ALLOW_ANY\"},\"policyCheckFailOpen\":false,\"priorityClassName\":\"\",\"proxy\":{\"accessLogEncoding\":\"TEXT\",\"accessLogFile\":\"\",\"accessLogFormat\":\"\",\"autoInject\":\"enabled\",\"clusterDomain\":\"cluster.local\",\"componentLogLevel\":\"\",\"concurrency\":2,\"dnsRefreshRate\":\"300s\",\"enableCoreDump\":false,\"envoyMetricsService\":{\"enabled\":true,\"host\":\"switchboard.service-mesh\",\"port\":15001},\"envoyStatsd\":{\"enabled\":false,\"host\":null,\"port\":null},\"excludeIPRanges\":\"\",\"excludeInboundPorts\":\"\",\"excludeOutboundPorts\":\"\",\"image\":\"proxy\",\"includeIPRanges\":\"127.1.2.3/32\",\"includeInboundPorts\":\"*\",\"kubevirtInterfaces\":\"\",\"logLevel\":\"info\",\"privileged\":false,\"readinessFailureThreshold\":30,\"readinessInitialDelaySeconds\":1,\"readinessPeriodSeconds\":2,\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"1024Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}},\"statusPort\":15020,\"tracer\":\"zipkin\"},\"proxy_init\":{\"image\":\"proxy_init\"},\"sds\":{\"enabled\":false,\"udsPath\":\"\",\"useNormalJwt\":false,\"useTrustworthyJwt\":false},\"tag\":\"f4b0db053ed277ba5335e7c2e88e505445b4ac92\",\"tracer\":{\"datadog\":{\"address\":\"$(HOST_IP):8126\"},\"lightstep\":{\"accessToken\":\"\",\"address\":\"\",\"cacertPath\":\"\",\"secure\":true},\"zipkin\":{\"address\":\"\"}},\"trustDomain\":\"\",\"useMCP\":false},\"image\":\"mixer\",\"nodeSelector\":{},\"podAnnotations\":{},\"podAntiAffinityLabelSelector\":[],\"podAntiAffinityTermLabelSelector\":[],\"policy\":{\"autoscaleEnabled\":true,\"autoscaleMax\":5,\"autoscaleMin\":1,\"cpu\":{\"targetAverageUtilization\":80},\"enabled\":false,\"replicaCount\":1},\"telemetry\":{\"autoscaleEnabled\":true,\"autoscaleMax\":5,\"autoscaleMin\":1,\"cpu\":{\"targetAverageUtilization\":80},\"enabled\":false,\"loadshedding\":{\"latencyThreshold\":\"100ms\",\"mode\":\"enforce\"},\"replicaCount\":1,\"resources\":{\"limits\":{\"cpu\":\"4800m\",\"memory\":\"4G\"},\"requests\":{\"cpu\":\"1000m\",\"memory\":\"1G\"}},\"sessionAffinityEnabled\":false},\"templates\":{\"useTemplateCRDs\":false},\"tolerations\":[]},\"nodeagent\":{\"enabled\":false},\"pilot\":{\"autoscaleEnabled\":true,\"autoscaleMax\":5,\"autoscaleMin\":1,\"cpu\":{\"targetAverageUtilization\":80},\"enabled\":true,\"env\":{\"GODEBUG\":\"gctrace=1\",\"PILOT_PUSH_THROTTLE\":100},\"global\":{\"arch\":{\"amd64\":2,\"ppc64le\":2,\"s390x\":2},\"configValidation\":false,\"controlPlaneSecurityEnabled\":false,\"defaultNodeSelector\":{},\"defaultPodDisruptionBudget\":{\"enabled\":false},\"defaultResources\":{\"requests\":{\"cpu\":\"10m\"}},\"defaultTolerations\":[],\"disablePolicyChecks\":true,\"enableHelmTest\":false,\"enableTracing\":false,\"hub\":\"ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging\",\"imagePullPolicy\":\"IfNotPresent\",\"imagePullSecrets\":null,\"k8sIngress\":{\"enableHttps\":false,\"enabled\":false,\"gatewayName\":\"ingressgateway\"},\"localityLbSetting\":{},\"logging\":{\"level\":\"default:info\"},\"meshExpansion\":{\"enabled\":false,\"useILB\":false},\"meshNetworks\":{},\"monitoringPort\":15014,\"mtls\":{\"enabled\":false},\"multiCluster\":{\"enabled\":false},\"oneNamespace\":false,\"outboundTrafficPolicy\":{\"mode\":\"ALLOW_ANY\"},\"policyCheckFailOpen\":false,\"priorityClassName\":\"\",\"proxy\":{\"accessLogEncoding\":\"TEXT\",\"accessLogFile\":\"\",\"accessLogFormat\":\"\",\"autoInject\":\"enabled\",\"clusterDomain\":\"cluster.local\",\"componentLogLevel\":\"\",\"concurrency\":2,\"dnsRefreshRate\":\"300s\",\"enableCoreDump\":false,\"envoyMetricsService\":{\"enabled\":true,\"host\":\"switchboard.service-mesh\",\"port\":15001},\"envoyStatsd\":{\"enabled\":false,\"host\":null,\"port\":null},\"excludeIPRanges\":\"\",\"excludeInboundPorts\":\"\",\"excludeOutboundPorts\":\"\",\"image\":\"proxy\",\"includeIPRanges\":\"127.1.2.3/32\",\"includeInboundPorts\":\"*\",\"kubevirtInterfaces\":\"\",\"logLevel\":\"info\",\"privileged\":false,\"readinessFailureThreshold\":30,\"readinessInitialDelaySeconds\":1,\"readinessPeriodSeconds\":2,\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"1024Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}},\"statusPort\":15020,\"tracer\":\"zipkin\"},\"proxy_init\":{\"image\":\"proxy_init\"},\"sds\":{\"enabled\":false,\"udsPath\":\"\",\"useNormalJwt\":false,\"useTrustworthyJwt\":false},\"tag\":\"f4b0db053ed277ba5335e7c2e88e505445b4ac92\",\"tracer\":{\"datadog\":{\"address\":\"$(HOST_IP):8126\"},\"lightstep\":{\"accessToken\":\"\",\"address\":\"\",\"cacertPath\":\"\",\"secure\":true},\"zipkin\":{\"address\":\"\"}},\"trustDomain\":\"\",\"useMCP\":false},\"image\":\"pilot\",\"keepaliveMaxServerConnectionAge\":\"30m\",\"nodeSelector\":{},\"podAntiAffinityLabelSelector\":[],\"podAntiAffinityTermLabelSelector\":[],\"resources\":{\"requests\":{\"cpu\":\"500m\",\"memory\":\"2048Mi\"}},\"sidecar\":true,\"tolerations\":[],\"traceSampling\":1},\"prometheus\":{\"enabled\":false},\"security\":{\"enabled\":false},\"sidecarInjectorWebhook\":{\"alwaysInjectSelector\":[],\"enableNamespacesByDefault\":false,\"enabled\":true,\"global\":{\"arch\":{\"amd64\":2,\"ppc64le\":2,\"s390x\":2},\"configValidation\":false,\"controlPlaneSecurityEnabled\":false,\"defaultNodeSelector\":{},\"defaultPodDisruptionBudget\":{\"enabled\":false},\"defaultResources\":{\"requests\":{\"cpu\":\"10m\"}},\"defaultTolerations\":[],\"disablePolicyChecks\":true,\"enableHelmTest\":false,\"enableTracing\":false,\"hub\":\"ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging\",\"imagePullPolicy\":\"IfNotPresent\",\"imagePullSecrets\":null,\"k8sIngress\":{\"enableHttps\":false,\"enabled\":false,\"gatewayName\":\"ingressgateway\"},\"localityLbSetting\":{},\"logging\":{\"level\":\"default:info\"},\"meshExpansion\":{\"enabled\":false,\"useILB\":false},\"meshNetworks\":{},\"monitoringPort\":15014,\"mtls\":{\"enabled\":false},\"multiCluster\":{\"enabled\":false},\"oneNamespace\":false,\"outboundTrafficPolicy\":{\"mode\":\"ALLOW_ANY\"},\"policyCheckFailOpen\":false,\"priorityClassName\":\"\",\"proxy\":{\"accessLogEncoding\":\"TEXT\",\"accessLogFile\":\"\",\"accessLogFormat\":\"\",\"autoInject\":\"enabled\",\"clusterDomain\":\"cluster.local\",\"componentLogLevel\":\"\",\"concurrency\":2,\"dnsRefreshRate\":\"300s\",\"enableCoreDump\":false,\"envoyMetricsService\":{\"enabled\":true,\"host\":\"switchboard.service-mesh\",\"port\":15001},\"envoyStatsd\":{\"enabled\":false,\"host\":null,\"port\":null},\"excludeIPRanges\":\"\",\"excludeInboundPorts\":\"\",\"excludeOutboundPorts\":\"\",\"image\":\"proxy\",\"includeIPRanges\":\"127.1.2.3/32\",\"includeInboundPorts\":\"*\",\"kubevirtInterfaces\":\"\",\"logLevel\":\"info\",\"privileged\":false,\"readinessFailureThreshold\":30,\"readinessInitialDelaySeconds\":1,\"readinessPeriodSeconds\":2,\"resources\":{\"limits\":{\"cpu\":\"2000m\",\"memory\":\"1024Mi\"},\"requests\":{\"cpu\":\"100m\",\"memory\":\"128Mi\"}},\"statusPort\":15020,\"tracer\":\"zipkin\"},\"proxy_init\":{\"image\":\"proxy_init\"},\"sds\":{\"enabled\":false,\"udsPath\":\"\",\"useNormalJwt\":false,\"useTrustworthyJwt\":false},\"tag\":\"f4b0db053ed277ba5335e7c2e88e505445b4ac92\",\"tracer\":{\"datadog\":{\"address\":\"$(HOST_IP):8126\"},\"lightstep\":{\"accessToken\":\"\",\"address\":\"\",\"cacertPath\":\"\",\"secure\":true},\"zipkin\":{\"address\":\"\"}},\"trustDomain\":\"\",\"useMCP\":false},\"image\":\"sidecar_injector\",\"neverInjectSelector\":[],\"nodeSelector\":{},\"podAntiAffinityLabelSelector\":[],\"podAntiAffinityTermLabelSelector\":[],\"replicaCount\":1,\"rewriteAppHTTPProbe\":false,\"tolerations\":[]},\"tracing\":{\"enabled\":false}}",
  },
  kind: "ConfigMap",
  metadata: {
    labels: {
      app: "istio",
      istio: "sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
  },
}
