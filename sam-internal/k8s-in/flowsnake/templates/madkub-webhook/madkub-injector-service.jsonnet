local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_test then
{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "madkub-injector",
        namespace: "flowsnake",
    },
    spec: {
        ports: [{
            port: 443,
            targetPort: 8443
        }],
        selector: {
            app: "madkub-injector",
        },
    }
} else "SKIP"
