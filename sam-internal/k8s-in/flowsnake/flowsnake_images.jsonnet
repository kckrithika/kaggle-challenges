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
            fleetService_image_tag: "565",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "565",
            ingressDefaultBackend_image_tag: "565",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001730-c7caec88",
            zookeeper_image_tag: "345",
            deployer_image_tag: "sam-0001730-c7caec88",
            version_mapping: {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "0.9.5": 487,
                  "0.9.6": "jenkins-dva-transformation-flowsnake-platform-0.9.6-ldap-hotfix-5-itest",
                  "0.9.7": 9999999999,
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
            fleetService_image_tag: "565",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "565",
            ingressDefaultBackend_image_tag: "565",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001730-c7caec88",
            zookeeper_image_tag: "345",
            deployer_image_tag: "sam-0001730-c7caec88",
            version_mapping: {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "0.9.5": 487,
                  "0.9.6": "jenkins-dva-transformation-flowsnake-platform-0.9.6-ldap-hotfix-5-itest",
                  "0.9.7": 9999999999,
                },
                # ignore this section, require by std.manifestIni
                sections: {
                },
            },
        },

        ### Release Phase 4
        "4": {
            canary_image_tag: "345",
            cert_secretizer_image_tag: "565",
            es_image_tag: "503",
            fleetService_image_tag: "565",
            glok_image_tag: "472",
            ingressControllerNginx_image_tag: "565",
            ingressDefaultBackend_image_tag: "565",
            kibana_image_tag: "345",
            logloader_image_tag: "468",
            logstash_image_tag: "468",
            madkub_image_tag: "1.0.0-0000062-dca2d8d1",
            nodeMonitor_image_tag: "403",
            watchdog_image_tag: "sam-0001730-c7caec88",
            zookeeper_image_tag: "345",
            deployer_image_tag: "sam-0001730-c7caec88",
            version_mapping: {
                main: {
                  "0.9.1": 377,
                  "0.9.2": 403,
                  "0.9.3": 427,
                  "0.9.4": 447,
                  "0.9.5": 487,
                  "0.9.6": "jenkins-dva-transformation-flowsnake-platform-0.9.6-ldap-hotfix-5-itest",
                  "0.9.7": 9999999999,
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
    canary: flowsnakeconfig.registry + "/flowsnake-canary:" + $.per_phase[$.phase].canary_image_tag,
    cert_secretizer: flowsnakeconfig.registry + "/flowsnake-cert-secretizer:" + $.per_phase[$.phase].cert_secretizer_image_tag,
    es: flowsnakeconfig.registry + "/flowsnake-elasticsearch:" + $.per_phase[$.phase].es_image_tag,
    fleet_service: flowsnakeconfig.registry + "/flowsnake-fleet-service:" + $.per_phase[$.phase].fleetService_image_tag,
    glok: flowsnakeconfig.registry + "/flowsnake-kafka:" + $.per_phase[$.phase].glok_image_tag,
    ingress_controller_nginx: flowsnakeconfig.registry + "/flowsnake-ingress-controller-nginx:" + $.per_phase[$.phase].ingressControllerNginx_image_tag,
    ingress_default_backend: flowsnakeconfig.registry + "/flowsnake-ingress-default-backend:" + $.per_phase[$.phase].ingressDefaultBackend_image_tag,
    kibana: flowsnakeconfig.registry + "/flowsnake-kibana:" + $.per_phase[$.phase].kibana_image_tag,
    logloader: flowsnakeconfig.registry + "/flowsnake-logloader:" + $.per_phase[$.phase].logloader_image_tag,
    logstash: flowsnakeconfig.registry + "/flowsnake-logstash:" + $.per_phase[$.phase].logstash_image_tag,
    node_monitor: flowsnakeconfig.registry + "/flowsnake-node-monitor:" + $.per_phase[$.phase].nodeMonitor_image_tag,
    zookeeper: flowsnakeconfig.registry + "/flowsnake-zookeeper:" + $.per_phase[$.phase].zookeeper_image_tag,

    version_mapping: $.per_phase[$.phase].version_mapping,

    # Non-Flowsnake images
    deployer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].deployer_image_tag),
    watchdog: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].watchdog_image_tag),
    /* watchdog: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jinxing.wang/hypersam:20180124_165559.cbc44617.dirty.jinxingwang-wsm", */
    madkub: imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].madkub_image_tag),

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
}
