local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local utils = import "util_functions.jsonnet";
{
    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any hypersam image for a given kingdom,estate,template,image.
        # Template is the short name of the template.  For k8s-in/templates/samcontrol.jsonnet use "samcontrol"
        # Image name
        #
        # Example:
        #   "prd,prd-sam,samcontrol,hypersam": "sam-0000123-deadbeef",
    },


    ### Per-phase image tags
    per_phase: {
        ### Image tags we do not change very often
        # When you *do* need to change one of these images, just override in the phase(s) you want to change.
        # Once the override is deployed to all phases, update the default and delete the overrides.
        default_image_tags: {
                cert_secretizer_image_tag: "716",
                es_image_tag: "503",
                fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-788-3-itest",
                testData_image_tag: "681",
                glok_image_tag: "472",  # NOTE: THIS MUST NOT CHANGE. As of Aug 2018, this image is no longer built by the flowsnake-platform project.
                ingressControllerNginx_image_tag: 662,
                ingressDefaultBackend_image_tag: 662,
                beacon_image_tag: "853c4db9f14805018be6f5e7607ffe65b5648822",
                kibana_image_tag: "345",
                impersonation_proxy_image_tag: "6-9ac63c5dfed1d4683add1289f98025d3226febd4",
                logloader_image_tag: "468",
                logstash_image_tag: "468",
                madkub_image_tag: "1.0.0-0000062-dca2d8d1",  # Don't forget to fix the cli params when this is changed
                nodeMonitor_image_tag: 662,
                watchdog_image_tag: "sam-0002015-fdb18963",
                watchdog_canary_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-698-itest",
                docker_daemon_watchdog_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-706-itest",
                node_controller_image_tag: "sam-0001970-a296421d",
                zookeeper_image_tag: "345",
                deployer_image_tag: "sam-0002470-52e6c77a",
                snapshoter_image_tag: "sam-0002052-bc0d9ea5",
                snapshot_consumer_image_tag: "sam-0002052-bc0d9ea5",
                kubedns_image_tag: "1.14.9",
                eventExporter_image_tag: "726",
                jdk8_base_tag: "33",
                madkub_injector_image_tag: "11",
                spark_operator_image_tag: "11",
                prometheus_funnel_image_tag: "19",
        },

        ### Release Phase minikube
        minikube: self.default_image_tags {
            cert_secretizer_image_tag: "minikube",
            es_image_tag: "minikube",
            fleetService_image_tag: "minikube",
            testData_image_tag: "minikube",
            glok_image_tag: "472",  # NOTE: THIS MUST NOT CHANGE. As of Aug 2018, this image is no longer built by the flowsnake-platform project.
            ingressControllerNginx_image_tag: "minikube",
            ingressDefaultBackend_image_tag: "minikube",
            kibana_image_tag: "minikube",
            logloader_image_tag: "minikube",
            logstash_image_tag: "minikube",
            madkub_image_tag: "minikube",
            nodeMonitor_image_tag: "minikube",
            zookeeper_image_tag: "minikube",
            spark_operator_image_tag: "minikube",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                # glok_retired: "foo", # W-4959832 (Remove logging to GloK and Glok/ZK/ES/Kibana/logloader) https://gus.my.salesforce.com/a07B0000004wnlxIAA
            },
            version_mapping: {
                main: {
                  minikube: "minikube",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 1 - Used for Flowsnake team-facing fleets
        "1": self.default_image_tags {

            // image tag overrides go here
            madkub_image_tag: "1.0.0-0000081-ddcaa288",

            cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            testData_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            ingressControllerNginx_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            ingressDefaultBackend_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            nodeMonitor_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            watchdog_canary_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            docker_daemon_watchdog_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",
            eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-810-9-itest",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                btrfs_watchdog_hard_reset: "",
                image_renames_and_canary_build_tags: "unverified",
                madkub_077_upgrade: "deploy-hand-in-hand-with-madkub_image_tag-change",
                dynamic_watchdogs: "verified in test",
                impersonation_proxy: "verified-in-prd-*",
                slb_ingress: "unverified",
                madkub_injector: "enabled",
                spark_operator: "enabled",
                spark_op_metrics: "enabled",
                spark_op_watchdog: "enabled",
                spark_op_remove_bogus_executor_account: "enabled",
            },
            version_mapping: {
                main: {
                  "0.9.10": 638,  # 0.9.10 didn't work the first time. Finally fixed here.
                  "0.10.0": 662,
                  "0.11.0": 681,
                  "0.11.0.sluice_fix": 691,
                  "0.12.0": 696,
                  "0.12.1": 10001,
                  # Due to a problem with the original push to Nexus we've been forced to not use that build
                  # We have opted to use the itest image built
                  "0.12.2": "jenkins-dva-transformation-flowsnake-platform-0.12.2-1-itest",
                  # Using a master branch build to run integration tests in test fleet for 0.12.3
                  "0.12.5": 10011,
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                }
                +
                # These are for developer testing only
                # only copy above to phase 2
                {
                  "spark-2.3-test": 672,
                  "sla-metrics-test": "jenkins-dva-transformation-flowsnake-platform-PR-656-9-itest",
                  branch_name_truncation: "jenkins-dva-transformation-flowsnake-platform-PR-680-5-itest",
                  khtest: "jenkins-dva-transformation-flowsnake-platform-PR-646-25-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 2 - Used for customer-facing prototyping fleets
        "2": self.default_image_tags {

            // image tag overrides go here
            madkub_image_tag: "1.0.0-0000081-ddcaa288",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                btrfs_watchdog_hard_reset: "",
                dynamic_watchdogs: "verified in dev",
                impersonation_proxy: "verified-in-prd-*",
                madkub_injector: "enabled",
                spark_op_metrics: "enabled",
                spark_operator: "enabled",
                madkub_077_upgrade: "",
            },
            version_mapping: {
                main: {
                  "0.9.10": 638,  # 0.9.10 didn't work the first time. Finally fixed here.
                  "spark-2.3-test": 672,
                  "0.10.0": 662,
                  "0.11.0": 681,
                  "0.11.0.sluice_fix": 691,
                  "0.12.0": 696,
                  "0.12.1": 10001,
                  "0.12.2": "jenkins-dva-transformation-flowsnake-platform-0.12.2-1-itest",  # see note in phase 1
                  "0.12.5": 10011,
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 3 - Canary on production fleets (plus critical-workload fleets in R&D data centers)
        "3": self.default_image_tags {

            // image tag overrides go here
            madkub_image_tag: "1.0.0-0000081-ddcaa288",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                dynamic_watchdogs: "verified in dev",
                impersonation_proxy: "verified-in-prd-*",
                madkub_injector: "enabled",
                spark_operator: "enabled",
                madkub_077_upgrade: "",
            },
            version_mapping: {
                main: {
                  "0.9.10": 638,  # 0.9.10 didn't work the first time. Finally fixed here.
                  "0.10.0": 662,
                  "0.11.0": 681,
                  "0.11.0.sluice_fix": 691,
                  "0.12.0": 696,
                  "0.12.1": 10001,
                  "0.12.2": "jenkins-dva-transformation-flowsnake-platform-0.12.2-1-itest",  # see note in phase 1
                  "0.12.5": 10011,
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 4 - Remaining production fleets
        "4": self.default_image_tags {
            ### DO NOT SET TAG OVERRIDES HERE
            ### Instead, update default_image_tags definition at top of this file and delete
            ### any overrides in other phases that are equal to the new defaults.

            feature_flags: {
                ### AFTER SETTING FEATURE FLAGS HERE:
                ### issue PR to deploy your changes. Then create a follow-on PR
                ### that deletes all the feature flags and conditional logic from
                ### the templates. This PR should not result in any k8s-out diffs.
            },
            version_mapping: {
                main: {
                  "0.12.2": "jenkins-dva-transformation-flowsnake-platform-0.12.2-1-itest",  # see note in phase 1
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### A very special phase 4 for IAD and ORD that preserves access to old versions used by CRE.
        ### TODO:  Remove when CRE is migrated to 0.12.2+
        "4-iad": self["4"] {

            version_mapping: {
                main: {
                  "0.10.0": 662,
                  "0.11.0": 681,
                  "0.12.0": 696,
                  "0.12.1": 10001,
                  "0.12.2": "jenkins-dva-transformation-flowsnake-platform-0.12.2-1-itest",  # see note in phase 1
                  "0.12.5": 10011,
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                sections: {},
            },

        },

        ### A very special phase 4 for IAD and ORD that preserves access to old versions used by CRE.
        ### TODO:  Remove when CRE is migrated to 0.12.2+
        "4-ord": self["4"] {

            version_mapping: {
                main: {
                  "0.10.0": 662,
                  "0.11.0": 681,
                  "0.12.0": 696,
                  "0.12.1": 10001,
                  "0.12.2": "jenkins-dva-transformation-flowsnake-platform-0.12.2-1-itest",  # see note in phase 1
                  "0.12.5": 10011,
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                sections: {},
            },

        },

        ### Phase 4 is undeployable due to image promotion volume - breaking it up further.
        "4-frf-par": self["4"] {
            ### DO NOT SET TAG OVERRIDES HERE
            ### Instead, update default_image_tags definition at top of this file and delete
            ### any overrides in other phases that are equal to the new defaults.

            feature_flags: {
                ### AFTER SETTING FEATURE FLAGS HERE:
                ### issue PR to deploy your changes. Then create a follow-on PR
                ### that deletes all the feature flags and conditional logic from
                ### the templates. This PR should not result in any k8s-out diffs.
            },
            version_mapping: {
                main: {
                  "0.12.2": "jenkins-dva-transformation-flowsnake-platform-0.12.2-1-itest",  # see note in phase 1
                  "0.12.5": 10011,
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        "4-dfw": self["4"] {
           cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",

           feature_flags: {
               dynamic_watchdogs: "yes",
           },

           version_mapping: {
                main: {
                  "0.12.5": "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        "4-ph2": self["4"] {
           cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",

           feature_flags: {
               dynamic_watchdogs: "yes",
           },

           version_mapping: {
                main: {
                  "0.12.5": "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        "4-hnd": self["4"] {
           cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",

           feature_flags: {
               dynamic_watchdogs: "yes",
           },

           version_mapping: {
                main: {
                  "0.12.5": "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        "4-ukb": self["4"] {
           cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",

           feature_flags: {
               dynamic_watchdogs: "yes",
           },

           version_mapping: {
                main: {
                  "0.12.5": "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        "4-phx": self["4"] {
           cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
           eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",

           feature_flags: {
               dynamic_watchdogs: "yes",
           },

           version_mapping: {
                main: {
                  "0.12.5": "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-820-2-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        "4-ia2": self["4"] {
           cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
           fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
           eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",

           feature_flags: {
               dynamic_watchdogs: "yes",
           },

           version_mapping: {
                main: {
                  "0.12.5": "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        "4-yul": self["4"] {
           cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
           fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
           eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",

           feature_flags: {
               dynamic_watchdogs: "yes",
           },

           version_mapping: {
                main: {
                  "0.12.5": "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
                  "0.12.5-wave": "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },
    },


    ### Phase kingdom/estate mapping
    phase: (
        if flowsnakeconfig.is_minikube then
            "minikube"
        else if estate == "prd-data-flowsnake_test" then
            "1"
        else if (kingdom == "prd" && estate != "prd-data-flowsnake") then
            "2"
        else if (estate == "prd-data-flowsnake") then
            "3"
        else if (estate == "iad-flowsnake_prod") then
            "4-iad"
        else if (estate == "ord-flowsnake_prod") then
            "4-ord"
        else if (estate == "frf-flowsnake_prod" || estate == "par-flowsnake_prod") then
            "4-frf-par"
        else if (estate == "dfw-flowsnake_prod") then
            "4-dfw"
        else if (estate == "ph2-flowsnake_prod") then
            "4-ph2"
        else if (estate == "hnd-flowsnake_prod") then
            "4-hnd"
        else if (estate == "ukb-flowsnake_prod") then
            "4-ukb"
        else if (estate == "phx-flowsnake_prod") then
            "4-phx"
        else if (estate == "ia2-flowsnake_prod") then
            "4-ia2"
        else if (estate == "yul-flowsnake_prod") then
            "4-yul"
        else
            "4"
        ),

    # These are the images used by the templates
    # Only change when image name change from https://git.soma.salesforce.com/dva-transformation/flowsnake-platform
    cert_secretizer: flowsnakeconfig.strata_registry + "/flowsnake-cert-secretizer:" + $.per_phase[$.phase].cert_secretizer_image_tag,
    es: flowsnakeconfig.strata_registry + "/flowsnake-elasticsearch:" + $.per_phase[$.phase].es_image_tag,
    fleet_service: flowsnakeconfig.strata_registry + "/flowsnake-fleet-service:" + $.per_phase[$.phase].fleetService_image_tag,
    event_exporter: flowsnakeconfig.strata_registry + "/flowsnake-event-exporter:" + $.per_phase[$.phase].eventExporter_image_tag,
    test_data: flowsnakeconfig.strata_registry + "/flowsnake-test-data:" + $.per_phase[$.phase].testData_image_tag,
    glok: flowsnakeconfig.strata_registry + "/flowsnake-kafka:" + $.per_phase[$.phase].glok_image_tag,
    impersonation_proxy: flowsnakeconfig.strata_registry + "/flowsnake-kubernetes-impersonation-proxy:" + $.per_phase[$.phase].impersonation_proxy_image_tag,
    ingress_controller_nginx: flowsnakeconfig.strata_registry + "/flowsnake-ingress-controller-nginx:" + $.per_phase[$.phase].ingressControllerNginx_image_tag,
    ingress_default_backend: flowsnakeconfig.strata_registry + "/flowsnake-ingress-default-backend:" + $.per_phase[$.phase].ingressDefaultBackend_image_tag,
    kibana: flowsnakeconfig.strata_registry + "/flowsnake-kibana:" + $.per_phase[$.phase].kibana_image_tag,
    logloader: flowsnakeconfig.strata_registry + "/flowsnake-logloader:" + $.per_phase[$.phase].logloader_image_tag,
    logstash: flowsnakeconfig.strata_registry + "/flowsnake-logstash:" + $.per_phase[$.phase].logstash_image_tag,
    node_monitor: flowsnakeconfig.strata_registry + "/flowsnake-node-monitor:" + $.per_phase[$.phase].nodeMonitor_image_tag,
    watchdog_canary: flowsnakeconfig.strata_registry + "/watchdog-canary:" + $.per_phase[$.phase].watchdog_canary_image_tag,
    docker_daemon_watchdog: flowsnakeconfig.strata_registry + "/docker-daemon-watchdog:" + $.per_phase[$.phase].docker_daemon_watchdog_image_tag,
    zookeeper: flowsnakeconfig.strata_registry + "/flowsnake-zookeeper:" + $.per_phase[$.phase].zookeeper_image_tag,
    madkub_injector: flowsnakeconfig.strata_registry + "/flowsnake-madkub-injector-webhook:" + $.per_phase[$.phase].madkub_injector_image_tag,
    spark_operator: flowsnakeconfig.strata_registry + "/kubernetes-spark-operator-2.4.0-sfdc-0.0.1:" + $.per_phase[$.phase].spark_operator_image_tag,

    feature_flags: $.per_phase[$.phase].feature_flags,
    version_mapping: $.per_phase[$.phase].version_mapping,

    # Non-Flowsnake images
    snapshoter: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].snapshoter_image_tag),
    snapshot_consumer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].snapshot_consumer_image_tag),
    deployer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].deployer_image_tag),
    watchdog: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].watchdog_image_tag),
    node_controller: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].node_controller_image_tag),
    madkub: if flowsnakeconfig.is_minikube then flowsnakeconfig.strata_registry + "/madkub:" + $.per_phase[$.phase].madkub_image_tag else imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub_image_tag),
    beacon: flowsnakeconfig.registry + "/sfci/servicelibs/beacon:" + $.per_phase[$.phase].beacon_image_tag,
    kubedns: flowsnakeconfig.strata_registry + "/k8s-dns-kube-dns:" + $.per_phase[$.phase].kubedns_image_tag,
    kubednsmasq: flowsnakeconfig.strata_registry + "/k8s-dns-dnsmasq-nanny:" + $.per_phase[$.phase].kubedns_image_tag,
    kubednssidecar: flowsnakeconfig.strata_registry + "/k8s-dns-sidecar:" + $.per_phase[$.phase].kubedns_image_tag,
    # Used by synthetic-dns-check; possible future use for other config-map-script-based helper-pods
    jdk8_base: flowsnakeconfig.strata_registry + "/sfdc_centos7_jdk8:" + $.per_phase[$.phase].jdk8_base_tag,

    prometheus_scraper: flowsnakeconfig.strata_registry + "/prome_for_k8s:" + $.per_phase[$.phase].prometheus_funnel_image_tag,
    funnel_writer: flowsnakeconfig.strata_registry + "/funnel_writer:" + $.per_phase[$.phase].prometheus_funnel_image_tag,

    # image function logic borrowed from samimages.jsonnet. We currently do not use the override functionality,
    # but benefit from the automatic DC-correct determination of which artifactrepo to use.
    #
    # image_functions needs to know the filename of the template we are processing
    # Each template must set this at time of importing this file, for example:
    #
    # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
    #
    # Then we pass this again into image_functions at time of import.
    templateFilename:: error "templateFilename must be passed at time of import",
    local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },

    # List of images that the Flowsnake control plane deploys dynamically
    # Images are promoted if they are explicitly referenced in a manifest. To effect promotion of images
    # we only refer to in dynamically created in Kubernetes resources, we list them here for inclusion
    # in a bogus manifest. Note: only images from the three magic prefixes /dva, /sfci, and /tnrp are
    # eligible for promotion.
    # Airflow, redis, and postgresql are not being built hence cannot be promoted
    flowsnakeImagesToPromote: [
       "flowsnake-spark-driver_2.1.0",
       "flowsnake-spark-master_2.1.0",
       "flowsnake-spark-worker_2.1.0",
       "flowsnake-spark-history-server_2.1.0",
       "flowsnake-spark-driver_2.3.0",
       "flowsnake-spark-master_2.3.0",
       "flowsnake-spark-worker_2.3.0",
       "flowsnake-spark-history-server_2.3.0",
       "flowsnake-rewriting-proxy",
       "flowsnake-local-kafka",
       "flowsnake-local-zookeeper",
       "flowsnake-kafka-rest-proxy",
       "flowsnake-spark-token-renewer",
       "flowsnake-spark-secret-updater",
       # "flowsnake-tensorflow-python27",
       # "flowsnake-tensorflow-python35",
       # "flowsnake-storm-worker",
       # "flowsnake-storm-nimbus",
       # "flowsnake-storm-submitter",
       # "flowsnake-storm-ui",
       "flowsnake-test-data",
       # Airflow prototype build broke, so we stopped building it for now.
       #"flowsnake-airflow-webserver",
       #"flowsnake-airflow-scheduler",
       #"flowsnake-airflow-worker",
       # "flowsnake-postgresql",
       # "flowsnake-redis",
       "flowsnake-environment-service",
       "flowsnake-stream-production-monitor",
       "flowsnake-kafka-configurator",
       "flowsnake-sluice-configurator",
       "flowsnake-kafka-connect",
       "flowsnake-job-flowsnake-demo-job",
       # "flowsnake-job-flowsnake-storm-demo-job",
       # "flowsnake-job-flowsnake-airflow-dags",
       "flowsnake-job-flowsnake-spark-local-mode-demo-job",
       "flowsnake-zookeeper",
       "flowsnake-logstash",
    ],

    # Use this to manage the release of versions that change the set of images we build.
    # Key is the user-facing version name, not the associated Docker tag.
    flowsnakeImagesToPromoteOverrides: {
        # This isn't a real release version, it's just a list used for all versions
        # before 0.11.0 consolidated here to avoid repetition
        "__pre-spark-2.3": [
            "flowsnake-spark-driver",
            "flowsnake-spark-master",
            "flowsnake-spark-worker",
            "flowsnake-spark-history-server",
            "flowsnake-rewriting-proxy",
            "flowsnake-local-kafka",
            "flowsnake-local-zookeeper",
            "flowsnake-kafka-rest-proxy",
            "flowsnake-spark-token-renewer",
            "flowsnake-spark-secret-updater",
            "flowsnake-tensorflow-python27",
            "flowsnake-tensorflow-python35",
            "flowsnake-storm-worker",
            "flowsnake-storm-nimbus",
            "flowsnake-storm-submitter",
            "flowsnake-storm-ui",
            "flowsnake-test-data",
            # Airflow prototype build broke, so we stopped building it for now.
            #"flowsnake-airflow-webserver",
            #"flowsnake-airflow-scheduler",
            #"flowsnake-airflow-worker",
            "flowsnake-postgresql",
            "flowsnake-redis",
            "flowsnake-environment-service",
            "flowsnake-stream-production-monitor",
            "flowsnake-kafka-configurator",
            "flowsnake-sluice-configurator",
            "flowsnake-kafka-connect",
            "flowsnake-job-flowsnake-demo-job",
            "flowsnake-job-flowsnake-storm-demo-job",
            "flowsnake-job-flowsnake-airflow-dags",
            "flowsnake-job-flowsnake-spark-local-mode-demo-job",
            "flowsnake-zookeeper",
            "flowsnake-logstash",
        ],
        "0.12.5-wave": [
           "flowsnake-spark-driver_2.3.0",
           "flowsnake-spark-master_2.3.0",
           "flowsnake-spark-worker_2.3.0",
           "flowsnake-spark-history-server_2.3.0",
           "flowsnake-rewriting-proxy",
           "flowsnake-local-kafka",
           "flowsnake-local-zookeeper",
           "flowsnake-kafka-rest-proxy",
           "flowsnake-spark-token-renewer",
           "flowsnake-spark-secret-updater",
           "flowsnake-test-data",
           "flowsnake-environment-service",
           "flowsnake-stream-production-monitor",
           "flowsnake-kafka-configurator",
           "flowsnake-sluice-configurator",
           "flowsnake-kafka-connect",
           "flowsnake-zookeeper",
           "flowsnake-logstash",
        ],
        # Aliases for pre-0.11.0 versions
        "0.9.10": self['__pre-spark-2.3'],
        "0.10.0": self['__pre-spark-2.3'],
    },
}
