local flowsnakeconfig = import "flowsnake_config.jsonnet";

# TODO: sam audodeployer needs to support this type
if false then
{
    apiVersion: "admissionregistration.k8s.io/v1beta1",
    kind: "MutatingWebhookConfiguration",
    metadata: {
        name: "madkub-container-spec",
        namespace: "flowsnake",
    },
    webhooks: [{
        name: "madkub-injector.flowsnake.sfdc.net",
        failurePolicy: "Fail",
        clientConfig: {
            caBundle: "", # Optional, but a k8s bug requires this to be set in 1.9.7
            service: {
                name: "madkub-injector",
                namespace: "flowsnake",
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
