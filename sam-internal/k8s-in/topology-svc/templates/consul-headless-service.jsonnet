# Headless service for Consul server DNS entries. This service should only
# point to Consul servers. this service can be used to communicate directly
# to a server agent.

local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

if configs.kingdom == 'mvp' then {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
        name: 'consul-headless',
        namespace: topologysvcNamespace,
        labels: {} + configs.pcnEnableLabel,
        annotations: {
             # This must be set in addition to publishNotReadyAddresses due
             # to an open issue where it may not work:
             # https://github.com/kubernetes/kubernetes/issues/58662
             'service.alpha.kubernetes.io/tolerate-unready-endpoints': 'true',
             # To skip swagger failure's with error:
             # found invalid field publishNotReadyAddresses for v1.ServiceSpec
             "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    spec: {
        clusterIP: 'None',
        # We want the servers to become available even if they're not ready
        # since this DNS is also used for join operations.
        publishNotReadyAddresses: true,
        selector: {
            app: 'consul-server',
        },
        ports: [
            {
                name: 'http',
                port: 8500,
                targetPort: 8500,
            },
            {
                name: 'serflan-tcp',
                protocol: 'TCP',
                port: 8301,
                targetPort: 8301,
            },
            {
                name: 'serflan-udp',
                protocol: 'UDP',
                port: 8301,
                targetPort: 8301,
            },
            {
                name: 'serfwan-tcp',
                protocol: 'TCP',
                port: 8302,
                targetPort: 8302,
            },
            {
                name: 'serfwan-udp',
                protocol: 'UDP',
                port: 8302,
                targetPort: 8302,
            },
            {
                name: 'server',
                port: 8300,
                targetPort: 8300,
            },
        ],
    },
} else "SKIP"
