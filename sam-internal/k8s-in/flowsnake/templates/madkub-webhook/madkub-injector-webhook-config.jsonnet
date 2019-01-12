local flowsnakeconfig = import "flowsnake_config.jsonnet";

# TODO: sam audodeployer needs to support this type
if false then
{
    apiVersion: "admissionregistration.k8s.io/v1beta1",
    wind: "MutatingWebhookConfiguration",
    metadata: {
        name: "madkub-container-spec",
        namespace: "flowsnake",
    },
    webhooks: [{
        name: "madkub-injector.flowsnake.sfdc.net",
        failurePolicy: "Fail",
        clientConfig: {
            service: {
                name: "madkub-injector",
                namespace: "default",
                path: "/"
            }
        },
        rules: [{
            operations: [ "CREATE", "UPDATE" ],
            apiGroups: [""],
            apiVersions: ["v1"],
            resources: ["pods"],
        }],
        namespaceSelector: {
            matchLabels: {
                "madkub-injector": "enabled"
            }
        }
    }]
} else "SKIP"
