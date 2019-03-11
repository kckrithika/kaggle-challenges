local configs = import "config.jsonnet";
local ports = import "portconfig.jsonnet";

# SFProxy for devmvp needs a LoadBalancer service to provision a regional TCP LoadBalancer.
# SAM manifest translation only supports internal load balancers.
# Declare this as a native k8s resource for now.
local casamSFProxyLoadBalancerEnabled = (configs.estate == "gsf-core-devmvp-sam2-sam");

if casamSFProxyLoadBalancerEnabled then {
  kind: "Service",
  apiVersion: "v1",
  metadata: {
    name: "casam-sfproxy-lb",
    namespace: "core-on-sam",
    labels: {
      name: "casam-sfproxy-lb",
      sam_app: "devmvp-sfproxy"
    } + configs.pcnEnableLabel,
  },
  spec: {
    type: "LoadBalancer",
    # CASAM needs the client source IP to be preserved. This requires "externalTrafficPolicy: Local".
    # See https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    externalTrafficPolicy: "Local",
    healthCheckNodePort: ports.slb.casamMVP_SFProxyHealthCheckNodePort,

    # Manually-provisioned static IP ("casam-sfproxy"). See https://console.cloud.google.com/networking/addresses/list?project=gsf-core-devmvp-sam2&pli=1
    loadBalancerIP: "35.193.207.80",

    ports: [
    # sfproxy isn't currently configured to listen for plaintext http requests.
    # Disabled until https://git.soma.salesforce.com/frontend-gateway/sfproxy/blob/master/config/core-on-sam/sfproxy-config.yaml.template#L33
    # is updated.
    #   {
    #     name: "http",
    #     protocol: "TCP",
    #     port: 80,
    #     targetPort: 120??,
    #   },
      {
        name: "https",
        protocol: 'TCP',
        port: 443,
        nodePort: ports.slb.casamMVP_SFProxyHTTPSNodePort,
        targetPort: 12060,
      },
      {
        name: "mtls",
        protocol: "TCP",
        port: 8443,
        nodePort: ports.slb.casamMVP_SFProxyMTLSNodePort,
        targetPort: 12060,
      },
    ],
    selector: {
      sam_app: "devmvp-sfproxy",
    },
  },
} else "SKIP"
