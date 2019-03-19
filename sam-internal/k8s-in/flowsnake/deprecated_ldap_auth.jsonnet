local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_v1_enabled then {
    auth_groups: (if std.objectHas(self.auth_groups_map, kingdom + "/" + estate) then $.auth_groups_map[kingdom + "/" + estate] else []),

    // DEPRECATED: Used for deploying Flowsnake versions <= 0.9.6.
    // Map from fleet (kingdom/estate) to list of auth groups authorized to access it.
    auth_groups_map: {
        "prd/prd-data-flowsnake": [
            "Flowsnake_Ops_Platform",
            "Security-Analytics",
            "alerting_flowsnake",
            "dbvisibility",
            "IoT-RM-Flowsnake",
            "FS_Rackbot",
            "MCeventing",
            "Analytics Service Ownership",
            "CRE_AD",
            "Lightning_Instrumentation",
            "Analytics-DataPool",
            "DSS_FLOWSNAKE_SERVICE",
            "ServiceProtection",
            "collection_flowsnake",
            "key_infrastructure",
        ],
        "prd/prd-dev-flowsnake_iot_test": [
            "Flowsnake_Ops_Platform",
            "IoT-RM-Flowsnake",
            "CRE_AD",
            "Analytics-DataPool",
        ],
        "prd/prd-minikube-small-flowsnake": [
            "Flowsnake_Ops_Platform",
        ],
        "prd/prd-minikube-big-flowsnake": [
            "Flowsnake_Ops_Platform",
        ],
    },
} else "SKIP"
