local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_images = import "flowsnake_images.jsonnet";
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
        "frf-flowsnake_prod": "flowsnake-frf.data.sfdc.net",
        "par-flowsnake_prod": "flowsnake-par.data.sfdc.net",
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
        "frf-flowsnake_prod": "api",
        "par-flowsnake_prod": "api",
        "prd-minikube-small-flowsnake": "api-minikube",
        "prd-minikube-big-flowsnake": "api-minikube",
    },
    default_image_pull_policy: if self.is_minikube then "Never" else "IfNotPresent",
    deepsea_enabled_estates: [
        "prd-data-flowsnake",
        "prd-data-flowsnake_test",
    ],
    deepsea_enabled: std.count(self.deepsea_enabled_estates, estate) > 0,
    // Note: true if pki_agent working. Includes both "enabled" and "in-transition" Puppet settings
    // False for Minikube, which supports MadKub for tenant certs but does not have PKI agent running on the
    // node itself.
    host_pki_agent_enabled: !self.is_minikube,
    // Prefer cert_services certs on these estates. (But use MadDog cabundle if maddog_enabled)
    cert_services_preferred_estates: [
        "prd-data-flowsnake",
        "prd-dev-flowsnake_iot_test",
    ],
    cert_services_preferred: std.count(self.cert_services_preferred_estates, estate) == 1,
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
    snapshots_enabled: !self.is_minikube,
    registry: if self.is_minikube then "minikube" else configs.registry,
    strata_registry: if self.is_minikube then "minikube" else configs.registry + "/dva",
    funnel_vip: "ajna0-funnel1-0-" + kingdom + ".data.sfdc.net",
    funnel_vip_and_port: $.funnel_vip + ":80",
    funnel_endpoint: "http://" + $.funnel_vip_and_port,
    madkub_endpoint: if self.is_minikube then "https://madkubserver:32007" else "https://10.254.208.254:32007",  // TODO: Fix kubedns so we do not need the IP
    maddog_endpoint: if self.is_minikube then "https://maddog-onebox:8443" else configs.maddogEndpoint,
    kubedns_manifests_enabled: !self.is_minikube,
    # Performance impact of logging DNS queries unknown. In test fleet alone it is ~5000 per minute. Presume this can
    # only be done temporarily.
    kubedns_cache_size: 50000,
    kubedns_synthetic_requests_estates: {
        "prd-data-flowsnake_test": {
            replicas: 5,
            rate: 100,  # requests per second per replica
        },
        "iad-flowsnake_prod": {
            replicas: 20,
            rate: 50,  # requests per second per replica
        },
    },
    # Query logging theoretically independent of synthetic requests, for now we enable them together.
    kubedns_log_queries: std.objectHas(self.kubedns_synthetic_requests_estates, estate),
    kubedns_synthetic_requests: std.objectHas(self.kubedns_synthetic_requests_estates, estate),
    kubedns_synthetic_requests_config: if std.objectHas(self.kubedns_synthetic_requests_estates, estate) then
        self.kubedns_synthetic_requests_estates[estate] else {},
    node_controller_enabled: !self.is_minikube,
}
