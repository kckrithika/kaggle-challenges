# NOTE: Do NOT override base OR modify base for team specific/whitelist rules

local config = import "../k8s-overwrite.jsonnet";
local util = import "../../util.jsonnet";

local schemaID = "k8sConfigs";

{
    # List of regex env name must match
    envVarNamePattern:: [
        "^[-._a-zA-Z][-._a-zA-Z0-9]*$"
    ],


    # List of Requirements for StatfulSet
    statefulSetSpecRequirements:: [
        "serviceName"
    ],


    # IsQualifiedName Rule from Kubernetes apimachinery
    isQualifiedName:: {
        oneOf: [            
            # For one part names without '/'
            {
                pattern: "^([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9]$",
                maxLength: 63
            },

            # For two parts with a '/'
            {
                allOf: [
                    # Make sure the 1st part matches DNS1123Subdomain regex and 2nd part match qualifiedName regex
                    { pattern: "^([a-z0-9]([-a-z0-9]*[a-z0-9])?(\\.[a-z0-9]([-a-z0-9]*[a-z0-9])?)*)/([A-Za-z0-9][-A-Za-z0-9_.]*)?[A-Za-z0-9]$" },
                    # Make sure the max length for the 1st part is 253 and 2nd part is 63
                    { pattern: "^.{1,253}/.{1,63}$" },
                ],
            },
        ]
    },


    # If Key is 'pool' and Operator is 'In', then there must only be 1 Value
    affinityValidation:: {
        "if": {
            allOf: [
                { properties: { key: { enum: [ "pool" ] } } },
                { properties: { operator: { enum: [ "In" ] } } },
            ]
        },
        "then": {
            properties: { 
                values: {
                    minItems: 1,
                    maxItems: 1
                } 
            },
        },
    },
}