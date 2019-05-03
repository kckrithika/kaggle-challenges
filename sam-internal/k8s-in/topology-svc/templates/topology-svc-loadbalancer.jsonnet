local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

if configs.kingdom == 'mvp' then {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
        name: 'topology-svc-internal-lb',
        namespace: topologysvcNamespace,
        labels: {
            app: 'topology-svc-internal-lb',
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
            app: 'topology-svc-internal',
        },
        ports: [
          {
             name: 'http',
             port: 80,
             targetPort: 7022,
          },
          {
              name: 'http1-tls',
              port: 443,
              targetPort: 7442,
          },
          {
             name: 'http-mgmt',
             port: 15372,
             targetPort: 15372,
          },
        ],
    },
} else 'SKIP'
