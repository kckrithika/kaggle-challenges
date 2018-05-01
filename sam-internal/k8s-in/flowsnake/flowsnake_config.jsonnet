local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeimage = import "flowsnake_images.jsonnet";
local configs = import "config.jsonnet";
local util = import "util_functions.jsonnet";
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
        "prd-data-flowsnake_test": "flowsnake-test1-0-prd.data.sfdc.net",
        // Production VIPs (flowsnake_worker_prod estate roles) are defined in estates:
        // https://git.soma.salesforce.com/estates/estates/blob/master/conf/vips.yaml
        "iad-flowsnake_prod": "flowsnake-iad.data.sfdc.net",
        "ord-flowsnake_prod": "flowsnake-ord.data.sfdc.net",
        "phx-flowsnake_prod": "flowsnake-phx.data.sfdc.net",
        // minikube fake VIPs
        "prd-minikube-small-flowsnake": "prd-minikube-small-flowsnake.data.sfdc.net",
        "prd-minikube-big-flowsnake": "prd-minikube-big-flowsnake.data.sfdc.net",
    },
    fleet_api_roles: {
        "prd-data-flowsnake": "api",
        "prd-dev-flowsnake_iot_test": "api-dev",
        "prd-data-flowsnake_test": "api-test",
        "iad-flowsnake_prod": "api",
        "ord-flowsnake_prod": "api",
        "phx-flowsnake_prod": "api",
        "prd-minikube-small-flowsnake": "api-minikube",
        "prd-minikube-big-flowsnake": "api-minikube",
    },
    watchdog_email_frequency: if estate == "prd-data-flowsnake_test" then "72h" else "10m",
    watchdog_email_frequency_kuberesources: "72h",
    deepsea_enabled_estates: [
        "prd-data-flowsnake",
        "prd-data-flowsnake_test",
    ],
    deepsea_enabled: std.count(self.deepsea_enabled_estates, estate) > 0,
    // Note: maddog_enabled if pki_agent working. Includes both "enabled" and "in-transition" Puppet settings
    maddog_enabled: !self.is_minikube,
    // Prefer cert_services certs on these estates. (But use MadDog cabundle if maddog_enabled)
    cert_services_preferred_estates: [
        "prd-data-flowsnake",
        "prd-dev-flowsnake_iot_test",
    ],
    cert_services_preferred: std.count(self.cert_services_preferred_estates, estate) == 1,
    sdn_pre_deployment_estates: [
        "phx-flowsnake_prod",
    ],
    sdn_during_deployment_estates: [
    ],
    sdn_pre_deployment: std.count(self.sdn_pre_deployment_estates, estate) == 1,
    sdn_during_deployment: std.count(self.sdn_during_deployment_estates, estate) == 1,
    sdn_done_deployment: std.count(self.sdn_done_deployment_estates, estate) == 1,
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
    is_test: (
        estate == "prd-data-flowsnake_test"
    ),
    registry: if self.is_minikube then "minikube" else configs.registry,
    strata_registry: if self.is_minikube then "minikube" else configs.registry + "/dva",
    funnel_vip: "ajna0-funnel1-0-" + kingdom + ".data.sfdc.net",
    funnel_vip_and_port: $.funnel_vip + ":80",
    funnel_endpoint: "http://" + $.funnel_vip_and_port,
    madkub_endpoint: if self.is_minikube then "https://madkubserver:32007" else "https://10.254.208.254:32007",  // TODO: Fix kubedns so we do not need the IP
    maddog_endpoint: if self.is_minikube then "https://maddog-onebox:8443" else "https://all.pkicontroller.pki.blank." + kingdom + ".prod.non-estates.sfdcsd.net:8443",
    sdn_enabled: !(self.is_minikube),
    elastic_search_enabled: (
        estate == "prd-data-flowsnake" ||
        estate == "prd-data-flowsnake_test" ||
        estate == "prd-dev-flowsnake_iot_test" ||
        (self.is_minikube && !self.is_minikube_small)
    ),
    kubedns_manifests_enabled: (
        estate == "iad-flowsnake_prod" ||
        estate == "prd-data-flowsnake_test" ||
        estate == "ord-flowsnake_prod" ||
        estate == "phx-flowsnake_prod"
    ),
}
