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
        name: 'consul-internal-lb',
        namespace: topologysvcNamespace,
        labels: {
            app: 'consul-internal-lb',
        } + configs.pcnEnableLabel,
        annotations: {
            "cloud.google.com/load-balancer-type": "Internal",
        },
    },
    spec: {
        type: 'LoadBalancer',
        externalTrafficPolicy: 'Cluster',
        sessionAffinity: 'None',
        selector: {
            app: 'consul-internal-server',
        },
        ports: [
            {
                name: 'http',
                port: 8500,
                targetPort: 7014,
            },
            {
                name: 'http-tls',
                port: 443,
                targetPort: 7442,
            },
            {
                name: 'serflan-tcp',
                port: 8301,
                targetPort: 8301,
            },
            {
                name: 'serfwan-tcp',
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
