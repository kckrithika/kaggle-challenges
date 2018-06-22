local configs = import "config.jsonnet";

if configs.kingdom == "prd" then {
    apiVersion: "extensions/v1beta1",
    kind: "ThirdPartyResource",
    metadata: {
        name: "sam-app.samapp.salesforce.com",
        labels: {} + configs.ownerLabel.sam,
    },
    description: "A specification of a SAM application",
    versions: [
        {
            name: "v1",
        },
    ],
} else "SKIP"
