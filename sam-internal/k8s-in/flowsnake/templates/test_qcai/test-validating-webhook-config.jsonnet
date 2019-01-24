local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_test then
{
    apiVersion: "admissionregistration.k8s.io/v1beta1",
    kind: "ValidatingWebhookConfiguration",
    metadata: {
        name: "validating-webhook-config",
        annotations: {
            "manifestctl.sam.data.sfdc.net/swagger": "disable",
        },
    },
    webhooks: [{
        name: "validating-webhook-test.flowsnake.sfdc.net",
        failurePolicy: "Fail",
        clientConfig: {
            url: "https://localhost",
        },
        rules: [{
            operations: [ "CREATE", "UPDATE" ],
            apiGroups: [""],
            apiVersions: ["v1"],
            resources: ["pods"],
        }],
    }],
    namespaceSelector: {
        matchLabels: {
            "webhook-test": "enabled"
        }
    }
} else "SKIP"
