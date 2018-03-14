local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    is_minikube: std.startsWith(estate, "prd-minikube"),
    is_minikube_small: std.startsWith(estate, "prd-minikube-small"),
    fleet_name_overrides: {
        "prd-data-flowsnake": "sfdc-prd",
        "prd-dev-flowsnake_iot_test": "sfdc-prd-iot-poc",
    },
    fleet_vips: {
        // These PRD VIPs are missing from vips.yaml but can be found in
        // https://git.soma.salesforce.com/estates/estates/blob/master/kingdoms/prd/vip-cnames.json
        // prd-data-flowsnake has a pretty/preferred CNAME that predates estate-based VIP configuration.
        "prd-data-flowsnake": "flowsnake-prd.data.sfdc.net",
        "prd-dev-flowsnake_iot_test": "dev0shared0-flowsnakeiottest1-0-prd.data.sfdc.net",
        "prd-data-flowsnake_test": "flowsnake-test1-0-prd.data.sfdc.net",  //Does not work yet

        // Production VIPs (flowsnake_worker_prod estate roles) are defined in estates:
        // https://git.soma.salesforce.com/estates/estates/blob/master/conf/vips.yaml
        "iad-flowsnake_prod": "flowsnake-iad.data.sfdc.net",
        "ord-flowsnake_prod": "flowsnake-ord.data.sfdc.net",
        "phx-flowsnake_prod": "flowsnake-phx.data.sfdc.net",

    },
    watchdog_email_frequency: if estate == "prd-data-flowsnake_test" then "72h" else "10m",
    watchdog_email_frequency_kuberesources: "72h",
    deepsea_enabled_estates: [
        "prd-data-flowsnake",
        "prd-data-flowsnake_test",
    ],
    deepsea_enabled: std.count(self.deepsea_enabled_estates, estate) > 0,
    maddog_disabled_estates: [
    ],
    maddog_enabled: !self.is_minikube && std.count(self.maddog_disabled_estates, estate) == 0,

    host_ca_cert_path: if self.maddog_enabled then
        "/etc/pki_service/ca/cabundle.pem"
      else
        "/data/certs/ca.crt",
    host_platform_client_cert_path: if self.maddog_enabled then
        "/etc/pki_service/platform/platform-client/certificates/platform-client.pem"
      else
        "/data/certs/hostcert.crt",
    host_platform_client_key_path: if self.maddog_enabled then
        "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem"
      else
        "/data/certs/hostcert.key",

    fleet_name: if self.is_minikube then
            # See flowsnake-platform/flowsnake-config
            "minikube"
        else if std.objectHas(self.fleet_name_overrides, estate) then
            $.fleet_name_overrides[estate]
        else
            estate,
    registry: if self.is_minikube then "minikube" else "dva-registry.internal.salesforce.com/dva",
    funnel_vip: "ajna0-funnel1-0-" + kingdom + ".data.sfdc.net",
    funnel_vip_and_port: $.funnel_vip + ":80",
    funnel_endpoint: "http://" + $.funnel_vip_and_port,

    sdn_enabled: !(self.is_minikube),
}
