local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    registry: "dva-registry.internal.salesforce.com/dva",
    fleet_name: (if std.objectHas(self.fleet_name_overrides, kingdom + "/" + estate) then $.fleet_name_overrides[kingdom + "/" + estate] else estate),
    fleet_name_overrides: {
        "prd/prd-data-flowsnake": "sfdc-prd",
        "prd/prd-data-flowsnake_test": "prd-data-flowsnake_test",
        "prd/prd-dev-flowsnake_iot_test": "sfdc-prd-iot-poc",
    },
    deepsea_enabled: [
        "prd/prd-data-flowsnake",
        "prd/prd-data-flowsnake_test",
    ],
}
