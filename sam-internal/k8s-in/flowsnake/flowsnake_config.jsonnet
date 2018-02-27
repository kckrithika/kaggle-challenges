local estate = std.extVar("estate");
{
    is_minikube: std.startsWith(estate, "prd-minikube"),
    is_minikube_small: std.startsWith(estate, "prd-minikube-small"),
    fleet_name_overrides: {
        "prd-data-flowsnake": "sfdc-prd",
        "prd-dev-flowsnake_iot_test": "sfdc-prd-iot-poc",
    },
    fleet_vips: {
        "prd-data-flowsnake": "flowsnake-prd.data.sfdc.net",
        "prd-dev-flowsnake_iot_test": "dev0shared0-flowsnakeiottest1-0-prd.data.sfdc.net",
        "prd-data-flowsnake_test": "no-vips-place-holder.prd.data.sdfc.net",
    },
    watchdog_email_frequency: if estate == "prd-data-flowsnake_test" then "72h" else "10m",
    watchdog_email_frequency_kuberesources: "72h",
    deepsea_enabled_estates: [
        "prd-data-flowsnake",
        "prd-data-flowsnake_test",
    ],
    deepsea_enabled: std.count(self.deepsea_enabled_estates, estate) > 0,
    maddog_disabled_estates: [
        "prd-data-flowsnake",
        "prd-dev-flowsnake_iot_test",
    ],
    maddog_enabled: !self.is_minikube && std.count(self.maddog_disabled_estates, estate) == 0,
    fleet_name: if self.is_minikube then
            # See flowsnake-platform/flowsnake-config
            "minikube"
        else if std.objectHas(self.fleet_name_overrides, estate) then
            $.fleet_name_overrides[estate]
        else
            estate,
    registry: if self.is_minikube then "minikube" else "dva-registry.internal.salesforce.com/dva",
}
