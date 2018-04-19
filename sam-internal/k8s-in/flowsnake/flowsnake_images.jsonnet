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

        ### Release Phase 1 - image tags from strata build
        "1": {
            canary_image_tag: "345",
            cert_secretizer_image_tag: "565",
            es_image_tag: "503",
            fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-602-1-itest",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "571",
            ingressDefaultBackend_image_tag: "571",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001730-c7caec88",
            zookeeper_image_tag: "345",
            deployer_image_tag: "sam-0001730-c7caec88",
            kubedns_image_tag: "1.10.0",
            version_mapping: {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "0.9.5": 487,
                  "0.9.6": "jenkins-dva-transformation-flowsnake-platform-0.9.6-ldap-hotfix-5-itest",
                  "0.9.7": 571,
                }
                +
                # These are for developer testing only
                # only copy above to phase 2
                {
                  "0.9.7-itest": 565,
                  "0.9.7-mktest": "jenkins-dva-transformation-flowsnake-platform-madkub-sidecar-user-1-itest",
                  "0.9.7-patch-worker-secrets": 584,
                  "0.9.8-service-mesh-test": "jenkins-dva-transformation-flowsnake-platform-PR-604-1-itest",
                  "smtest-kh": "jenkins-dva-transformation-flowsnake-platform-PR-597-4-itest",
                  "jvmtest-lhn": "jenkins-dva-transformation-flowsnake-platform-jvm_options-1-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 2
        "2": {
            canary_image_tag: "345",
            cert_secretizer_image_tag: "565",
            es_image_tag: "503",
            fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-602-1-itest",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "571",
            ingressDefaultBackend_image_tag: "571",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001730-c7caec88",
            zookeeper_image_tag: "345",
            deployer_image_tag: "sam-0001730-c7caec88",
            kubedns_image_tag: "1.10.0",
            version_mapping: {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "0.9.5": 487,
                  "0.9.6": "jenkins-dva-transformation-flowsnake-platform-0.9.6-ldap-hotfix-5-itest",
                  "0.9.7": 571,
                  "0.9.7-mktest": "jenkins-dva-transformation-flowsnake-platform-madkub-sidecar-user-1-itest",  # temporary for IoT
                  "0.9.7-patch-worker-secrets": 584,  # temporary for IoT
                  "0.9.8-service-mesh-test": "599",  # ALSO temporary for IoT...
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 3
        "3": {
            canary_image_tag: "345",
            cert_secretizer_image_tag: "565",
            es_image_tag: "503",
            fleetService_image_tag: "571",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "571",
            ingressDefaultBackend_image_tag: "571",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001730-c7caec88",
            zookeeper_image_tag: "345",
            deployer_image_tag: "sam-0001730-c7caec88",
            kubedns_image_tag: "1.10.0",
            version_mapping: {
                main: {
                  "0.9.7": 571,
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 4
        "4": {
            canary_image_tag: "345",
            cert_secretizer_image_tag: "585",
            es_image_tag: "503",
            fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-589-1-itest",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "571",
            ingressDefaultBackend_image_tag: "571",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001730-c7caec88",
            zookeeper_image_tag: "345",
            deployer_image_tag: "sam-0001730-c7caec88",
            kubedns_image_tag: "1.10.0",
            version_mapping: {
                main: {
                  "0.9.7": 571,
                  "0.9.8-SNAPSHOT": "jenkins-dva-transformation-flowsnake-platform-PR-589-1-itest",
                  "0.9.7-595": "jenkins-dva-transformation-flowsnake-platform-PR-596-1-itest",
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        minikube: {
            canary_image_tag: "minikube",
            cert_secretizer_image_tag: "minikube",
            es_image_tag: "minikube",
            fleetService_image_tag: "minikube",
            glok_image_tag: "minikube",
            ingressControllerNginx_image_tag: "minikube",
            ingressDefaultBackend_image_tag: "minikube",
            kibana_image_tag: "minikube",
            logloader_image_tag: "minikube",
            logstash_image_tag: "minikube",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "minikube",
            zookeeper_image_tag: "minikube",
            kubedns_image_tag: "1.10.0",
            version_mapping: {
                main: {
                  minikube: "minikube",
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
        else if (kingdom == "prd") then
            "2"
        else if (kingdom == "phx") then
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
    glok: flowsnakeconfig.strata_registry + "/flowsnake-kafka:" + $.per_phase[$.phase].glok_image_tag,
    ingress_controller_nginx: flowsnakeconfig.strata_registry + "/flowsnake-ingress-controller-nginx:" + $.per_phase[$.phase].ingressControllerNginx_image_tag,
    ingress_default_backend: flowsnakeconfig.strata_registry + "/flowsnake-ingress-default-backend:" + $.per_phase[$.phase].ingressDefaultBackend_image_tag,
    kibana: flowsnakeconfig.strata_registry + "/flowsnake-kibana:" + $.per_phase[$.phase].kibana_image_tag,
    logloader: flowsnakeconfig.strata_registry + "/flowsnake-logloader:" + $.per_phase[$.phase].logloader_image_tag,
    logstash: flowsnakeconfig.strata_registry + "/flowsnake-logstash:" + $.per_phase[$.phase].logstash_image_tag,
    node_monitor: flowsnakeconfig.strata_registry + "/flowsnake-node-monitor:" + $.per_phase[$.phase].nodeMonitor_image_tag,
    zookeeper: flowsnakeconfig.strata_registry + "/flowsnake-zookeeper:" + $.per_phase[$.phase].zookeeper_image_tag,

    version_mapping: $.per_phase[$.phase].version_mapping,

    # Non-Flowsnake images
    deployer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].deployer_image_tag),
    watchdog: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].watchdog_image_tag),
    madkub: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub_image_tag),
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
        "flowsnake-airflow-webserver",
        "flowsnake-airflow-scheduler",
        "flowsnake-airflow-worker",
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
}
