# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "v1",
  data: {
    config: "policy: disabled\ntemplate: |-\n  initContainers:\n  - name: istio-init\n    image: \"ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/proxy_init:1.0.2\"\n    args:\n    - \"-p\"\n    - [[ .MeshConfig.ProxyListenPort ]]\n    - \"-u\"\n    - 1337\n    - \"-m\"\n    - [[ or (index .ObjectMeta.Annotations \"sidecar.istio.io/interceptionMode\") .ProxyConfig.InterceptionMode.String ]]\n    - \"-i\"\n    [[ if (isset .ObjectMeta.Annotations \"traffic.sidecar.istio.io/includeOutboundIPRanges\") -]]\n    - \"[[ index .ObjectMeta.Annotations \"traffic.sidecar.istio.io/includeOutboundIPRanges\"  ]]\"\n    [[ else -]]\n    - \"127.1.2.3/32\"\n    [[ end -]]\n    - \"-x\"\n    [[ if (isset .ObjectMeta.Annotations \"traffic.sidecar.istio.io/excludeOutboundIPRanges\") -]]\n    - \"[[ index .ObjectMeta.Annotations \"traffic.sidecar.istio.io/excludeOutboundIPRanges\"  ]]\"\n    [[ else -]]\n    - \"\"\n    [[ end -]]\n    - \"-b\"\n    [[ if (isset .ObjectMeta.Annotations \"traffic.sidecar.istio.io/includeInboundPorts\") -]]\n    - \"[[ index .ObjectMeta.Annotations \"traffic.sidecar.istio.io/includeInboundPorts\"  ]]\"\n    [[ else -]]\n    - [[ range .Spec.Containers -]][[ range .Ports -]][[ .ContainerPort -]], [[ end -]][[ end -]][[ end]]\n    - \"-d\"\n    [[ if (isset .ObjectMeta.Annotations \"traffic.sidecar.istio.io/excludeInboundPorts\") -]]\n    - \"[[ index .ObjectMeta.Annotations \"traffic.sidecar.istio.io/excludeInboundPorts\" ]]\"\n    [[ else -]]\n    - \"\"\n    [[ end -]]\n    imagePullPolicy: IfNotPresent\n    securityContext:\n      runAsNonRoot: false\n      runAsUser: 0\n      capabilities:\n        add:\n        - NET_ADMIN\n      restartPolicy: Always\n  \n  containers:\n  - name: istio-proxy\n    image: [[ if (isset .ObjectMeta.Annotations \"sidecar.istio.io/proxyImage\") -]]\n    \"[[ index .ObjectMeta.Annotations \"sidecar.istio.io/proxyImage\" ]]\"\n    [[ else -]]\n    ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/proxy:50d25caed2638ed29259a2be55ba2dc0ceb49b00\n    [[ end -]]\n    args:\n    - proxy\n    - sidecar\n    - --configPath\n    - [[ .ProxyConfig.ConfigPath ]]\n    - --binaryPath\n    - [[ .ProxyConfig.BinaryPath ]]\n    - --serviceCluster\n    [[ if ne \"\" (index .ObjectMeta.Labels \"app\") -]]\n    - [[ index .ObjectMeta.Labels \"app\" ]]\n    [[ else -]]\n    - \"istio-proxy\"\n    [[ end -]]\n    - --drainDuration\n    - [[ formatDuration .ProxyConfig.DrainDuration ]]\n    - --parentShutdownDuration\n    - [[ formatDuration .ProxyConfig.ParentShutdownDuration ]]\n    - --discoveryAddress\n    - [[ .ProxyConfig.DiscoveryAddress ]]\n    - --discoveryRefreshDelay\n    - [[ formatDuration .ProxyConfig.DiscoveryRefreshDelay ]]\n    - --zipkinAddress\n    - [[ .ProxyConfig.ZipkinAddress ]]\n    - --connectTimeout\n    - [[ formatDuration .ProxyConfig.ConnectTimeout ]]\n    - --proxyAdminPort\n    - [[ .ProxyConfig.ProxyAdminPort ]]\n    [[ if gt .ProxyConfig.Concurrency 0 -]]\n    - --concurrency\n    - [[ .ProxyConfig.Concurrency ]]\n    [[ end -]]\n    - --controlPlaneAuthPolicy\n    - [[ or (index .ObjectMeta.Annotations \"sidecar.istio.io/controlPlaneAuthPolicy\") .ProxyConfig.ControlPlaneAuthPolicy ]]\n    env:\n    - name: POD_NAME\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.name\n    - name: POD_NAMESPACE\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.namespace\n    - name: INSTANCE_IP\n      valueFrom:\n        fieldRef:\n          fieldPath: status.podIP\n    - name: ISTIO_META_POD_NAME\n      valueFrom:\n        fieldRef:\n          fieldPath: metadata.name\n    - name: ISTIO_META_INTERCEPTION_MODE\n      value: [[ or (index .ObjectMeta.Annotations \"sidecar.istio.io/interceptionMode\") .ProxyConfig.InterceptionMode.String ]]\n    imagePullPolicy: IfNotPresent\n    securityContext:\n      readOnlyRootFilesystem: true\n      [[ if eq (or (index .ObjectMeta.Annotations \"sidecar.istio.io/interceptionMode\") .ProxyConfig.InterceptionMode.String) \"TPROXY\" -]]\n      capabilities:\n        add:\n        - NET_ADMIN\n      runAsGroup: 1337\n      [[ else -]]\n      runAsUser: 1337\n      [[ end -]]\n    restartPolicy: Always\n    resources:\n      [[ if (isset .ObjectMeta.Annotations \"sidecar.istio.io/proxyCPU\") -]]\n      requests:\n        cpu: \"[[ index .ObjectMeta.Annotations \"sidecar.istio.io/proxyCPU\" ]]\"\n        memory: \"[[ index .ObjectMeta.Annotations \"sidecar.istio.io/proxyMemory\" ]]\"\n    [[ else -]]\n      requests:\n        cpu: 10m\n      \n    [[ end -]]\n    volumeMounts:\n    - mountPath: /etc/istio/proxy\n      name: istio-envoy\n    - mountPath: /etc/certs/root-cert.pem # Maddog certs mapped to istio certs default locations.\n      name: tls-server-cert               # Volume should be defined in Manifest file.\n      subPath: ca.pem\n    - mountPath: /etc/certs/cert-chain.pem\n      name: tls-server-cert\n      subPath: server/certificates/server.pem\n    - mountPath: /etc/certs/key.pem\n      name: tls-server-cert\n      subPath: server/keys/server-key.pem\n    - mountPath: /etc/certs/client.pem\n      name: tls-client-cert\n      subPath: client/certificates/client.pem\n    - mountPath: /etc/certs/client-key.pem\n      name: tls-client-cert\n      subPath: client/keys/client-key.pem\n  volumes:\n  - emptyDir:\n      medium: Memory\n    name: istio-envoy",
  },
  kind: "ConfigMap",
  metadata: {
    labels: {
      app: "istio",
      chart: "istio-1.0.1",
      heritage: "Tiller",
      istio: "sidecar-injector",
      release: "istio",
    },
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
  },
}
