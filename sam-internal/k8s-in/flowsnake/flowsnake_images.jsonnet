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
                canary_image_tag: 662,
                cert_secretizer_image_tag: 662,
                es_image_tag: "503",
                fleetService_image_tag: "662",
                testData_image_tag: "638",
                glok_image_tag: "472",
                ingressControllerNginx_image_tag: 662,
                ingressDefaultBackend_image_tag: 662,
                beacon_image_tag: "853c4db9f14805018be6f5e7607ffe65b5648822",
                kibana_image_tag: "345",
                logloader_image_tag: "468",
                logstash_image_tag: "468",
                madkub_image_tag: "1.0.0-0000062-dca2d8d1",
                nodeMonitor_image_tag: 662,
                watchdog_image_tag: "sam-0001730-c7caec88",
                watchdog_canary_image_tag: "664",
                node_controller_image_tag: "sam-0001970-a296421d",
                zookeeper_image_tag: "345",
                deployer_image_tag: "sam-0001730-c7caec88",
                kubedns_image_tag: "1.10.0",
        },

        ### Release Phase minikube
        minikube: self.default_image_tags {
            canary_image_tag: "minikube",
            cert_secretizer_image_tag: "minikube",
            es_image_tag: "minikube",
            fleetService_image_tag: "minikube",
            testData_image_tag: "minikube",
            glok_image_tag: "minikube",
            ingressControllerNginx_image_tag: "minikube",
            ingressDefaultBackend_image_tag: "minikube",
            kibana_image_tag: "minikube",
            logloader_image_tag: "minikube",
            logstash_image_tag: "minikube",
            madkub_image_tag: "minikube",
            nodeMonitor_image_tag: "minikube",
            zookeeper_image_tag: "minikube",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                simplify_elk_replicas: "foo",
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

            watchdog_image_tag: "sam-0002015-fdb18963",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                simplify_elk_replicas: "foo",  # Untested; Elastic Search totally borked due to cert issues.
                watchdog_configmap_update: "foo",
                watchdog_canaries: "foo",  #Verified in Test Fleet - https://salesforce.quip.com/MCYHA4Z0Gfpa
            },
            version_mapping: {
                main: {
                  "0.9.10": 638,  # 0.9.10 didn't work the first time. Finally fixed here.
                  "0.10.0": 662,
                }
                +
                # These are for developer testing only
                # only copy above to phase 2
                {
                  "spark-2.3-test": "jenkins-dva-transformation-flowsnake-platform-PR-630-29-itest",
                  "sla-metrics-test": "jenkins-dva-transformation-flowsnake-platform-PR-656-9-itest",
                  "vg-maddog-test": "jenkins-dva-transformation-flowsnake-platform-PR-675-1-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 2 - Used for customer-facing prototyping fleets
        "2": self.default_image_tags {

            watchdog_image_tag: "sam-0002015-fdb18963",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                watchdog_configmap_update: "foo",
                watchdog_canaries: "foo",  #Verified in IoT Fleet - https://salesforce.quip.com/MCYHA4Z0Gfpa
            },
            version_mapping: {
                main: {
                  "0.9.7": 571,
                  "0.9.8": 607,
                  "0.9.10": 638,  # 0.9.10 didn't work the first time. Finally fixed here.
                  "spark-2.3-test": "jenkins-dva-transformation-flowsnake-platform-PR-630-29-itest",
                  "vg-maddog-test": "jenkins-dva-transformation-flowsnake-platform-PR-675-1-itest",
                  "0.10.0": 662,
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 3 - Canary on production fleets (plus critical-workload fleets in R&D data centers)
        "3": self.default_image_tags {

            watchdog_image_tag: "sam-0002015-fdb18963",

            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                watchdog_configmap_update: "foo",
                watchdog_canaries: "foo",  #Untested, requires verification before promotion to phase 4
            },
            version_mapping: {
                main: {
                  "0.9.10": 638,  # 0.9.10 didn't work the first time. Finally fixed here.
                  "spark-2.3-test": "jenkins-dva-transformation-flowsnake-platform-PR-630-29-itest",
                  "vg-maddog-test": "jenkins-dva-transformation-flowsnake-platform-PR-675-1-itest",
                  "0.10.0": 662,
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
                  "0.9.7": 571,
                  "0.9.8": 607,
                  "0.9.10": 638,  # 0.9.10 didn't work the first time. Finally fixed here.
                  "0.10.0": 662,
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
        else if (estate == "prd-data-flowsnake" || kingdom == "phx") then
            "3"
        else
            "4"
        ),

    # These are the images used by the templates
    # Only change when image name change from https://git.soma.salesforce.com/dva-transformation/flowsnake-platform
    canary: flowsnakeconfig.strata_registry + "/flowsnake-canary:" + $.per_phase[$.phase].canary_image_tag,
    cert_secretizer: flowsnakeconfig.strata_registry + "/flowsnake-cert-secretizer:" + $.per_phase[$.phase].cert_secretizer_image_tag,
    es: flowsnakeconfig.strata_registry + "/flowsnake-elasticsearch:" + $.per_phase[$.phase].es_image_tag,
    fleet_service: flowsnakeconfig.strata_registry + "/flowsnake-fleet-service:" + $.per_phase[$.phase].fleetService_image_tag,
    test_data: flowsnakeconfig.strata_registry + "/flowsnake-test-data:" + $.per_phase[$.phase].testData_image_tag,
    glok: flowsnakeconfig.strata_registry + "/flowsnake-kafka:" + $.per_phase[$.phase].glok_image_tag,
    ingress_controller_nginx: flowsnakeconfig.strata_registry + "/flowsnake-ingress-controller-nginx:" + $.per_phase[$.phase].ingressControllerNginx_image_tag,
    ingress_default_backend: flowsnakeconfig.strata_registry + "/flowsnake-ingress-default-backend:" + $.per_phase[$.phase].ingressDefaultBackend_image_tag,
    kibana: flowsnakeconfig.strata_registry + "/flowsnake-kibana:" + $.per_phase[$.phase].kibana_image_tag,
    logloader: flowsnakeconfig.strata_registry + "/flowsnake-logloader:" + $.per_phase[$.phase].logloader_image_tag,
    logstash: flowsnakeconfig.strata_registry + "/flowsnake-logstash:" + $.per_phase[$.phase].logstash_image_tag,
    node_monitor: flowsnakeconfig.strata_registry + "/flowsnake-node-monitor:" + $.per_phase[$.phase].nodeMonitor_image_tag,
    watchdog_canary: flowsnakeconfig.strata_registry + "/watchdog-canary:" + $.per_phase[$.phase].watchdog_canary_image_tag,
    zookeeper: flowsnakeconfig.strata_registry + "/flowsnake-zookeeper:" + $.per_phase[$.phase].zookeeper_image_tag,

    feature_flags: $.per_phase[$.phase].feature_flags,
    version_mapping: $.per_phase[$.phase].version_mapping,

    # Non-Flowsnake images
    deployer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].deployer_image_tag),
    watchdog: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].watchdog_image_tag),
    node_controller: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].node_controller_image_tag),
    madkub: if flowsnakeconfig.is_minikube then flowsnakeconfig.strata_registry + "/madkub:" + $.per_phase[$.phase].madkub_image_tag else imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub_image_tag),
    beacon: flowsnakeconfig.registry + "/sfci/servicelibs/beacon:" + $.per_phase[$.phase].beacon_image_tag,
    kubedns: flowsnakeconfig.strata_registry + "/k8s-dns-kube-dns:" + $.per_phase[$.phase].kubedns_image_tag,
    kubednsmasq: flowsnakeconfig.strata_registry + "/k8s-dns-dnsmasq-nanny:" + $.per_phase[$.phase].kubedns_image_tag,
    kubednssidecar: flowsnakeconfig.strata_registry + "/k8s-dns-sidecar:" + $.per_phase[$.phase].kubedns_image_tag,

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
    # Images are promoted if they are explicitly referenced in a manifest. To effect promotion of images we only refer to in dynamically created in Kubernetes resources, we list them here for inclusion in a bogus manifest. Note: only images from the three magic prefixes /dva, /sfci, and /tnrp are eligible for promotion.
    flowsnakeImagesToPromote: [
        "flowsnake-spark-driver",
        "flowsnake-spark-master",
        "flowsnake-spark-worker",
        "flowsnake-spark-history-server",
        "flowsnake-rewriting-proxy",
        "flowsnake-local-kafka",
        "flowsnake-global-kafka",
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

    # Use this to manage the release of versions that change the set of images we build.
    # Key is the user-facing version name, not the associated Docker tag.
    flowsnakeImagesToPromoteOverrides: {
        "spark-2.3-test": [
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
           "flowsnake-global-kafka",
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
    },
}
