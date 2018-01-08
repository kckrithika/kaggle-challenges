local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - image tags from strata build
        "1": {
            "fleetService_image_tag": "468",
            "watchdog_image_tag": "sam-0001027-676096c4",
            "nodeMonitor_image_tag": "403",
            "ingressDefaultBackend_image_tag": "468",
            "ingressControllerNginx_image_tag" : "468",
            "logloader_image_tag": "468",
            "logstash_image_tag": "468",
            "es_image_tag": "345",
            "kibana_image_tag": "345",
            "zookeeper_image_tag": "345",
            "glok_image_tag": "472",
            "canary_image_tag": "345",
            "version_mapping": {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "094-snapshot-phoenix-fix": "spark-phoenix-fix-itest-ready",
                  "khtest": "disable-core-dumps-itest-ready",
                  "add-hive-to-spark-4-itest-ready": "add-hive-to-spark-4-itest-ready",
                  "kafka-one-test": "cm201711-kafka-one-upgrade-itest-ready",
                  "release-095-retry-itest-ready": "release-095-retry-itest-ready"
                }
                +
                # These are for developer testing only
                # only copy above to phase 2
                {
                  "0.0.1": 1
                },
                # ignore this section, require by std.manifestIni
                sections: {
                }
            }
        },

        ### Release Phase 2
        "2": {
            "fleetService_image_tag": "cascading-bullshit-fiasco-itest-ready",
            "watchdog_image_tag": "sam-0001027-676096c4",
            "nodeMonitor_image_tag": "403",
            "ingressDefaultBackend_image_tag": "345",
            "ingressControllerNginx_image_tag" : "345",
            "logloader_image_tag": "345",
            "logstash_image_tag": "345",
            "es_image_tag": "345",
            "kibana_image_tag": "345",
            "zookeeper_image_tag": "345",
            "glok_image_tag": "472",
            "canary_image_tag": "345",
            "version_mapping": {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "094-snapshot-phoenix-fix": "spark-phoenix-fix-itest-ready",
                  "khtest": "disable-core-dumps-itest-ready",
                  "add-hive-to-spark-4-itest-ready": "add-hive-to-spark-4-itest-ready",
                  "kafka-one-test": "cm201711-kafka-one-upgrade-itest-ready",
                  "release-095-retry-itest-ready": "release-095-retry-itest-ready"
                },
                # ignore this section, require by std.manifestIni
                sections: {
                }
            }
        },

        ### Release Phase 3
        "3": {
        },

        ### Release Phase 4
        "4": {
        },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-data-flowsnake_test") then
            "1"
        else if (kingdom == "prd") then
            "2"
        else if (kingdom == "frf" || kingdom == "yhu" || kingdom == "yul") then
            "3"
        else
            "4"
        ),

    # These are the images used by the templates
    # Only change when image name change from https://git.soma.salesforce.com/dva-transformation/flowsnake-platform
    version_mapping: $.per_phase[$.phase]["version_mapping"],
    ingress_controller_nginx: "dva-registry.internal.salesforce.com/dva/flowsnake-ingress-controller-nginx:" + $.per_phase[$.phase]["ingressControllerNginx_image_tag"],
    ingress_default_backend: "dva-registry.internal.salesforce.com/dva/flowsnake-ingress-default-backend:" + $.per_phase[$.phase]["ingressDefaultBackend_image_tag"],
    logloader: "dva-registry.internal.salesforce.com/dva/flowsnake-logloader:" + $.per_phase[$.phase]["logloader_image_tag"],
    logstash: "dva-registry.internal.salesforce.com/dva/flowsnake-logstash:" + $.per_phase[$.phase]["logstash_image_tag"],
    fleet_service: "dva-registry.internal.salesforce.com/dva/flowsnake-fleet-service:" + $.per_phase[$.phase]["fleetService_image_tag"],
    node_monitor: "dva-registry.internal.salesforce.com/dva/flowsnake-node-monitor:" + $.per_phase[$.phase]["nodeMonitor_image_tag"],
    es: "dva-registry.internal.salesforce.com/dva/flowsnake-elasticsearch:" + $.per_phase[$.phase]["es_image_tag"],
    kibana: "dva-registry.internal.salesforce.com/dva/flowsnake-kibana:" + $.per_phase[$.phase]["kibana_image_tag"],
    glok: "dva-registry.internal.salesforce.com/dva/flowsnake-kafka:" + $.per_phase[$.phase]["glok_image_tag"],
    zookeeper: "dva-registry.internal.salesforce.com/dva/flowsnake-zookeeper:" + $.per_phase[$.phase]["zookeeper_image_tag"],
    canary: "dva-registry.internal.salesforce.com/dva/flowsnake-canary:" + $.per_phase[$.phase]["canary_image_tag"],
    watchdog: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:" + $.per_phase[$.phase]["watchdog_image_tag"],
}
