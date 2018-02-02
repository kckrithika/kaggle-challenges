local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - image tags from strata build
        "1": {
            canary_image_tag: "345",
            es_image_tag: "503",
            fleetService_image_tag: "468",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "345",
            ingressDefaultBackend_image_tag: "345",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001622-cbc44617",
            zookeeper_image_tag: "345",
            version_mapping: {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "0.9.5": 487,
                  khtest: "disable-core-dumps-itest-ready",
                  "add-hive-to-spark-4-itest-ready": "add-hive-to-spark-4-itest-ready",
                  "kafka-one-test": "cm201711-kafka-one-upgrade-itest-ready",
                  "release-095-retry-itest-ready": "release-095-retry-itest-ready",
                }
                +
                # These are for developer testing only
                # only copy above to phase 2
                {
                  "0.0.1": 1,
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 2
        "2": {
            canary_image_tag: "345",
            es_image_tag: "503",
            fleetService_image_tag: "487",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "345",
            ingressDefaultBackend_image_tag: "345",
            kibana_image_tag: "345",
            logloader_image_tag: "345",
            logstash_image_tag: "468",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001622-cbc44617",
            zookeeper_image_tag: "345",
            version_mapping: {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "0.9.5": 487,
                  khtest: "disable-core-dumps-itest-ready",
                  "add-hive-to-spark-4-itest-ready": "add-hive-to-spark-4-itest-ready",
                  "kafka-one-test": "cm201711-kafka-one-upgrade-itest-ready",
                  "release-095-retry-itest-ready": "release-095-retry-itest-ready",
                  "hadoop-dep-test-itest-ready": "hadoop-dep-test-itest-ready",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
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
    canary: "dva-registry.internal.salesforce.com/dva/flowsnake-canary:" + $.per_phase[$.phase].canary_image_tag,
    es: "dva-registry.internal.salesforce.com/dva/flowsnake-elasticsearch:" + $.per_phase[$.phase].es_image_tag,
    fleet_service: "dva-registry.internal.salesforce.com/dva/flowsnake-fleet-service:" + $.per_phase[$.phase].fleetService_image_tag,
    glok: "dva-registry.internal.salesforce.com/dva/flowsnake-kafka:" + $.per_phase[$.phase].glok_image_tag,
    ingress_controller_nginx: "dva-registry.internal.salesforce.com/dva/flowsnake-ingress-controller-nginx:" + $.per_phase[$.phase].ingressControllerNginx_image_tag,
    ingress_default_backend: "dva-registry.internal.salesforce.com/dva/flowsnake-ingress-default-backend:" + $.per_phase[$.phase].ingressDefaultBackend_image_tag,
    kibana: "dva-registry.internal.salesforce.com/dva/flowsnake-kibana:" + $.per_phase[$.phase].kibana_image_tag,
    logloader: "dva-registry.internal.salesforce.com/dva/flowsnake-logloader:" + $.per_phase[$.phase].logloader_image_tag,
    logstash: "dva-registry.internal.salesforce.com/dva/flowsnake-logstash:" + $.per_phase[$.phase].logstash_image_tag,
    node_monitor: "dva-registry.internal.salesforce.com/dva/flowsnake-node-monitor:" + $.per_phase[$.phase].nodeMonitor_image_tag,
    version_mapping: $.per_phase[$.phase].version_mapping,
    /* watchdog: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:" + $.per_phase[$.phase].watchdog_image_tag, */
    watchdog: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jinxing.wang/hypersam:20180124_165559.cbc44617.dirty.jinxingwang-wsm",
    zookeeper: "dva-registry.internal.salesforce.com/dva/flowsnake-zookeeper:" + $.per_phase[$.phase].zookeeper_image_tag,
}
