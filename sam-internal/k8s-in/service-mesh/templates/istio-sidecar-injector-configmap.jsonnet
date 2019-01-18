local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";
local istioImages = (import "istio-images.jsonnet") + { templateFilename:: std.thisFile };

local params = {
  initContainerImage: istioImages.proxyinit,
  proxyContainerImage: istioImages.proxy,
  # Only include the "magic" mesh IP. All *.svc.mesh.sfdc.net subdomains will resolve to that address.
  includedOutboundIpRanges: "127.1.2.3/32",
  excludedOutboundIpRanges: "",
};

local sidecarConfig = |||
    policy: disabled
    template: |-
      initContainers:
      - name: istio-init
        image: %(initContainerImage)s
        args:
        - "-p"
        - [[ .MeshConfig.ProxyListenPort ]]
        - "-u"
        - 1337
        - "-m"
        - [[ or (index .ObjectMeta.Annotations "sidecar.istio.io/interceptionMode") .ProxyConfig.InterceptionMode.String ]]
        - "-i"
        [[ if (isset .ObjectMeta.Annotations "traffic.sidecar.istio.io/includeOutboundIPRanges") -]]
        - "[[ index .ObjectMeta.Annotations "traffic.sidecar.istio.io/includeOutboundIPRanges"  ]]"
        [[ else -]]
        - "%(includedOutboundIpRanges)s"
        [[ end -]]
        - "-x"
        [[ if (isset .ObjectMeta.Annotations "traffic.sidecar.istio.io/excludeOutboundIPRanges") -]]
        - "[[ index .ObjectMeta.Annotations "traffic.sidecar.istio.io/excludeOutboundIPRanges"  ]]"
        [[ else -]]
        - "%(excludedOutboundIpRanges)s"
        [[ end -]]
        - "-b"
        [[ if (isset .ObjectMeta.Annotations "traffic.sidecar.istio.io/includeInboundPorts") -]]
        - "[[ index .ObjectMeta.Annotations "traffic.sidecar.istio.io/includeInboundPorts"  ]]"
        [[ else -]]
        - [[ range .Spec.Containers -]][[ range .Ports -]][[ .ContainerPort -]], [[ end -]][[ end -]][[ end]]
        - "-d"
        [[ if (isset .ObjectMeta.Annotations "traffic.sidecar.istio.io/excludeInboundPorts") -]]
        - "[[ index .ObjectMeta.Annotations "traffic.sidecar.istio.io/excludeInboundPorts" ]]"
        [[ else -]]
        - [[ .ProxyConfig.ProxyAdminPort ]]
        [[ end -]]
        imagePullPolicy: IfNotPresent
        securityContext:
          runAsNonRoot: false
          runAsUser: 0
          capabilities:
            add:
            - NET_ADMIN
          restartPolicy: Always

      containers:
      - name: istio-proxy
        image: [[ if (isset .ObjectMeta.Annotations "sidecar.istio.io/proxyImage") -]]
        "[[ index .ObjectMeta.Annotations "sidecar.istio.io/proxyImage" ]]"
        [[ else -]]
        %(proxyContainerImage)s
        [[ end -]]
        args:
        - proxy
        - sidecar
        - --configPath
        - [[ .ProxyConfig.ConfigPath ]]
        - --binaryPath
        - [[ .ProxyConfig.BinaryPath ]]
        - --serviceCluster
        [[ if ne "" (index .ObjectMeta.Labels "app") -]]
        - [[ index .ObjectMeta.Labels "app" ]]
        [[ else -]]
        - "istio-proxy"
        [[ end -]]
        - --drainDuration
        - [[ formatDuration .ProxyConfig.DrainDuration ]]
        - --parentShutdownDuration
        - [[ formatDuration .ProxyConfig.ParentShutdownDuration ]]
        - --discoveryAddress
        - [[ .ProxyConfig.DiscoveryAddress ]]
        - --discoveryRefreshDelay
        - [[ formatDuration .ProxyConfig.DiscoveryRefreshDelay ]]
        - --zipkinAddress
        - [[ .ProxyConfig.ZipkinAddress ]]
        - --connectTimeout
        - [[ formatDuration .ProxyConfig.ConnectTimeout ]]
        - --statsdUdpAddress
        - [[ .ProxyConfig.StatsdUdpAddress ]]
        - --proxyAdminPort
        - [[ .ProxyConfig.ProxyAdminPort ]]
        [[ if gt .ProxyConfig.Concurrency 0 -]]
        - --concurrency
        - [[ .ProxyConfig.Concurrency ]]
        [[ end -]]
        - --controlPlaneAuthPolicy
        - [[ or (index .ObjectMeta.Annotations "sidecar.istio.io/controlPlaneAuthPolicy") .ProxyConfig.ControlPlaneAuthPolicy ]]
        env:
        - name: POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        - name: INSTANCE_IP
          valueFrom:
            fieldRef:
              fieldPath: status.podIP
        - name: ISTIO_META_POD_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.name
        - name: ISTIO_META_INTERCEPTION_MODE
          value: [[ or (index .ObjectMeta.Annotations "sidecar.istio.io/interceptionMode") .ProxyConfig.InterceptionMode.String ]]
        imagePullPolicy: IfNotPresent
        securityContext:
          readOnlyRootFilesystem: true
          [[ if eq (or (index .ObjectMeta.Annotations "sidecar.istio.io/interceptionMode") .ProxyConfig.InterceptionMode.String) "TPROXY" -]]
          capabilities:
            add:
            - NET_ADMIN
          runAsGroup: 1337
          [[ else -]]
          runAsUser: 1337
          [[ end -]]
        restartPolicy: Always
        resources:
          [[ if (isset .ObjectMeta.Annotations "sidecar.istio.io/proxyCPU") -]]
          requests:
            cpu: "[[ index .ObjectMeta.Annotations "sidecar.istio.io/proxyCPU" ]]"
            memory: "[[ index .ObjectMeta.Annotations "sidecar.istio.io/proxyMemory" ]]"
        [[ else -]]
          requests:
            cpu: 10m

        [[ end -]]
        volumeMounts:
        - mountPath: /etc/istio/proxy
          name: istio-envoy
        - mountPath: /etc/certs/root-cert.pem # Maddog certs mapped to istio certs default locations.
          name: tls-server-cert               # Volume should be defined in Manifest file.
          subPath: ca.pem
        - mountPath: /etc/certs/cert-chain.pem
          name: tls-server-cert
          subPath: server/certificates/server.pem
        - mountPath: /etc/certs/key.pem
          name: tls-server-cert
          subPath: server/keys/server-key.pem
        - mountPath: /etc/certs/client.pem
          name: tls-client-cert
          subPath: client/certificates/client.pem
        - mountPath: /etc/certs/client-key.pem
          name: tls-client-cert
          subPath: client/keys/client-key.pem
      volumes:
      - emptyDir:
          medium: Memory
        name: istio-envoy
|||;

{
  apiVersion: "v1",
  kind: "ConfigMap",
  metadata: {
    name: "istio-sidecar-injector",
    namespace: "mesh-control-plane",
    labels: {
      app: "istio",
      chart: "istio-1.0.1",
      istio: "sidecar-injector",
    },
  },
  data: {
    config: sidecarConfig % params,
  },
}
