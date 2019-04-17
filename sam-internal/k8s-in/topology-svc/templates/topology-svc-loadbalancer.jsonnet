local configs = import 'config.jsonnet';
local topologysvcimages = (import 'topology-svc-images.jsonnet') + { templateFilename:: std.thisFile };
local topologysvcNamespace = 'topology-svc';

if configs.kingdom == 'mvp' then {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
        name: 'topology-svc-lb',
        namespace: topologysvcNamespace,
        labels: {
            app: 'topology-svc-lb',
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
            app: 'topology-svc',
        },
        ports: [
          {
             name: 'http',
             port: 8080,
             targetPort: 8080,
          },
        ],
    },
} else 'SKIP'
