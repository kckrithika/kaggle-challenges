local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";
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
    registry: if self.is_minikube then
            "minikube"
        else if estate == "prd-data-flowsnake" ||
                estate == "prd-dev-flowsnake_iot_test" then
            "dva-registry.internal.salesforce.com/dva"
        else
            configs.registry + "/dva",
    funnel_vip: "ajna0-funnel1-0-" + kingdom + ".data.sfdc.net",
    funnel_vip_and_port: $.funnel_vip + ":80",
    funnel_endpoint: "http://" + $.funnel_vip_and_port,
    sdn_enabled: !(self.is_minikube),
    elastic_search_enabled: (
        estate == "prd-data-flowsnake" ||
        estate == "prd-data-flowsnake_test" ||
        estate == "prd-dev-flowsnake_iot_test" ||
        (self.is_minikube && !self.is_minikube_small)
    ),
    flowsnakeImageTagToPromote: [
    // comment out promoted iamge without remove to keep recover.
        345,
        571,
    ],
    flowsnakeImagesToPromote: [
        "flowsnake-spark-driver",
        "flowsnake-spark-master",
        "flowsnake-spark-worker",
        "flowsnake-spark-history-server",
        "flowsnake-rewriting-proxy",
        "flowsnake-kafka",
        "flowsnake-local-kafka",
        "flowsnake-global-kafka",
        "flowsnake-zookeeper",
        "flowsnake-local-zookeeper",
        "flowsnake-kafka-rest-proxy",
        "flowsnake-elasticsearch",
        "flowsnake-logstash",
        "flowsnake-kibana",
        "flowsnake-ingress-default-backend",
        "flowsnake-ingress-controller-nginx",
        "flowsnake-spark-token-renewer",
        "flowsnake-spark-secret-updater",
        "flowsnake-tensorflow-python27",
        "flowsnake-tensorflow-python35",
        "flowsnake-storm-worker",
        "flowsnake-storm-nimbus",
        "flowsnake-storm-submitter",
        "flowsnake-storm-ui",
        "flowsnake-test-data",
        "flowsnake-airflow-webserver",
        "flowsnake-airflow-scheduler",
        "flowsnake-airflow-worker",
        "flowsnake-postgresql",
        "flowsnake-redis",
        "flowsnake-fleet-service",
        "flowsnake-environment-service",
        "flowsnake-stream-production-monitor",
        "flowsnake-kafka-configurator",
        "flowsnake-sluice-configurator",
        "flowsnake-kafka-connect",
        "flowsnake-job-flowsnake-demo-job",
        "flowsnake-job-flowsnake-storm-demo-job",
        "flowsnake-job-flowsnake-airflow-dags",
        "flowsnake-job-flowsnake-spark-local-mode-demo-job",
        "flowsnake-logloader",
        "flowsnake-canary",
        "flowsnake-node-monitor",
        "flowsnake-cert-secretizer",
    ],
}
