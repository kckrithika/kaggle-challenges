local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    ### Per-phase image tags
    per_phase: {

        ### Release Phase 1 - image tags from strata build
        "1": {
            "image_tag": "468",
            "version_mapping": {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "094-snapshot-phoenix-fix": "spark-phoenix-fix-itest-ready",
                  "carl-zk-test": "zk-service-extirpation-itest-ready"
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
            "image_tag": "427",
            "version_mapping": {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "094-snapshot-phoenix-fix": "spark-phoenix-fix-itest-ready",
                  "carl-zk-test": "zk-service-extirpation-itest-ready"
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

    # Static images that do not go in phases
    # These fleet components don't need to change when deploying new version of flowsnake
    # Only change when needed
    static: {
        watchdogImage: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-release-candidate/tnrp/sam/hypersam:sam-0001027-676096c4",

        # WARNING: changing these image tags will result in data loss
        esImage: "345",
        kibanaImage: "345",
        zookeeperImage: "345",
        glokImage: "472",
        canaryImage: "345",
    },

    # These are the images used by the templates
    # Only change when image name change from https://git.soma.salesforce.com/dva-transformation/flowsnake-platform
    fleet_image_tag: $.per_phase[$.phase]["image_tag"],
    version_mapping: $.per_phase[$.phase]["version_mapping"],
    es: "dva-registry.internal.salesforce.com/dva/flowsnake-elasticsearch:" + $.static["esImage"],
    kibana: "dva-registry.internal.salesforce.com/dva/flowsnake-kibana:" + $.static["kibanaImage"],
    glok: "dva-registry.internal.salesforce.com/dva/flowsnake-kafka:" + $.static["glokImage"],
    zookeeper: "dva-registry.internal.salesforce.com/dva/flowsnake-zookeeper:" + $.static["zookeeperImage"],
    canary: "dva-registry.internal.salesforce.com/dva/flowsnake-canary:" + $.static["canaryImage"],
    watchdog: $.static["watchdogImage"],
}
