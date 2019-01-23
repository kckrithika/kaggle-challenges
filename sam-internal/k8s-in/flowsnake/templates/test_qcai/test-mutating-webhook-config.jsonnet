local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_test then
{
    apiVersion: "admissionregistration.k8s.io/v1beta1",
    kind: "MutatingWebhookConfiguration",
    metadata: {
        name: "mutating-webhook-config",
        namespace: "test-qcai",
        annotations: {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    webhooks: [{
        name: "webhook-test.flowsnake.sfdc.net",
        failurePolicy: "Fail",
        rules: [{
            operations: [ "CREATE", "UPDATE" ],
            apiGroups: [""],
            apiVersions: ["v1"],
            resources: ["pods"],
        }],
        namespaceSelector: {
            matchLabels: {
                "webhook-test": "enabled"
            }
        }
    }]
} else "SKIP"
