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

    per_phase: {
        # Promotion order is opposite of inheritance order. The final phase is the root of the inheritance, with
        # earlier phases inheriting from it and adding overrides to deploy experimental new releases.

        # Phase 1: prd-test fleet.
        # Only include new things not yet promoted to next phase. To promote, move line items to next phase.
        "1": self["2"] {
            image_tags+: {
                # jenkins-dva-transformation-flowsnake-platform-master-781-itest contains MoFo estates and Kevin's 5xx fixes
                cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                testData_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                ingressControllerNginx_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                ingressDefaultBackend_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                nodeMonitor_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                watchdog_canary_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                docker_daemon_watchdog_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                watchdog_image_tag: "2687-6c147b04d2d506c9fd591d50f400bd86c485b155",  # Slight formatting fix for cli-checker stdout/stderr to watchdog report email
                madkub_image_tag: "1.0.0-0000084-9f4a6ca6",  # Madkub server gets token for itself using host IP
                deployer_image_tag: "2653-de840aef94cedaeb0b971120b108b3570db4eb59",
                spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-operator-resource-quota-sfdc-12-itest",
            },
            feature_flags+: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                btrfs_watchdog_hard_reset: "",
                image_renames_and_canary_build_tags: "unverified",
                slb_ingress: "unverified",
                spark_application_quota_enforcement: "enabled",
            },
            # prd-test offers legacy version mappings. Phase 2 does not, so cannot inherit from there.
            # Start with 2-prd-dev (which also have legacy version mappings),
            # and then any cusomizations just for this fleet.
            version_mapping: $.per_phase["2-prd-dev"].version_mapping {
                "0.12.5": "jenkins-dva-transformation-flowsnake-platform-master-781-itest",  # jenkins-dva-transformation-flowsnake-platform-master-781-itest contains MoFo estates and Kevin's 5xx fixes
            },
        },
        # Phase 2: Remaining PRD fleets and production canary fleets.
        # Only include new things not yet promoted to next phase. To promote, move line items to next phase.
        "2": self["3"] {
            image_tags+: {
                cert_secretizer_image_tag: "716",  # TODO: This is _older_ than phase 3. Fix.
                eventExporter_image_tag: "726",  # TODO: This is _older_ than phase 3. Fix.
                fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-788-3-itest",  # TODO: This is _older_ than phase 3. Fix.
                watchdog_image_tag: "2687-6c147b04d2d506c9fd591d50f400bd86c485b155",  # Slight formatting fix for cli-checker stdout/stderr to watchdog report email
            },
            feature_flags+: {
                #spark_application_quota_enforcement: "enabled",
            },
            version_mapping+: {
                "0.12.5": 10011,  # TODO: Why is this different from production?
            },
        },
        # prd-dev: Exceptions vs the rest of phase 2 only
        "2-prd-dev": self["2"] {
            feature_flags+: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                btrfs_watchdog_hard_reset: "",  # Was promoted to prd-dev before phasing refactor
            },
            # prd-dev offers legacy version mappings. Phase 3 does not, so cannot inherit from there.
            # Start with 3-iad-ord (which also have legacy version mappings),
            # then apply overrides from generic phase 2, and then any customizations just for this fleet.
            version_mapping: $.per_phase["3-iad-ord"].version_mapping + super.version_mapping + {
            },
        },
        # prd-data: Exceptions vs. the rest of phase 2 only
        "2-prd-data": self["2"] {
            feature_flags+: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
            },
            # prd-data offers legacy version mappings. Phase 3 does not, so cannot inherit from there.
            # Start with 3-iad-ord (which also have legacy version mappings),
            # then apply overrides from generic phase 2, and then any cusomizations just for this fleet.
            # TODO: tidy up all these exceptions.
            version_mapping: $.per_phase["3-iad-ord"].version_mapping + super.version_mapping + {
                "0.10.0": 662,
                "0.12.0": 696,
                "0.12.1": 10001,
            },
        },
        # frf: Exceptions vs. the rest of phase 2 only
        "2-frf": self["2"] {
            # FRF was in sync the rest of phase 3 before the phasing refactor.
            # TODO: Let it begin canarying what the rest of phase 2 is doing.
            image_tags: $.per_phase["3"].image_tags,
            version_mapping: $.per_phase["3"].version_mapping,
        },
        # cdu: Exceptions vs. the rest of phase 2 only
        "2-cdu": self["2"] {
            # CDU was in sync the rest of 3-pcl before the phasing refactor.
            # TODO: Let it begin canarying what the rest of phase 2 is doing.
            image_tags: $.per_phase["3-pcl"].image_tags,
            version_mapping: $.per_phase["3-pcl"].version_mapping,  # Public cloud has different version mappings
        },
        # Phase 3: Remaining production fleets.
        # This is the defacto "default" set of items.
        "3": {
            image_tags: {
                es_image_tag: "503",
                testData_image_tag: "681",
                # TODO: Why are still still deploying Glok at all?
                glok_image_tag: "472",  # NOTE: THIS MUST NOT CHANGE. As of Aug 2018, this image is no longer built by the flowsnake-platform project.
                ingressControllerNginx_image_tag: 662,
                ingressDefaultBackend_image_tag: 662,
                beacon_image_tag: "853c4db9f14805018be6f5e7607ffe65b5648822",
                kibana_image_tag: "345",
                impersonation_proxy_image_tag: "8-9ced7803391be70dd7dc41cd3211800cda818f50",  # exec's nginx for signal propagation
                logloader_image_tag: "468",
                logstash_image_tag: "468",
                madkub_image_tag: "1.0.0-0000081-ddcaa288",
                nodeMonitor_image_tag: 662,
                watchdog_image_tag: "sam-0002015-fdb18963",
                watchdog_canary_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-698-itest",
                watchdog_spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-sample-apps-PR-2-1-itest",
                docker_daemon_watchdog_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-706-itest",
                node_controller_image_tag: "sam-0001970-a296421d",
                zookeeper_image_tag: "345",
                deployer_image_tag: "sam-0002470-52e6c77a",
                snapshoter_image_tag: "sam-0002052-bc0d9ea5",
                snapshot_consumer_image_tag: "sam-0002052-bc0d9ea5",
                kubedns_image_tag: "1.14.9",
                jdk8_base_tag: "33",
                madkub_injector_image_tag: "11",
                spark_operator_image_tag: "11",
                prometheus_funnel_image_tag: "34",
                cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
                fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
                eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
            },
            feature_flags: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
            },
            version_mapping: {
                "0.12.5": "jenkins-dva-transformation-flowsnake-platform-release-0_12_5-with-new-fleets-12-itest",
            },
        },
        # Public Cloud ("MoFo") exceptions to the rest of phase 3.
        "3-pcl": self["3"] {
            image_tags+: {
                # TODO: Get in sync with the rest of phase 3
                # In PCL, Madkub server needs to use host IP for token IP to get server token.
                madkub_image_tag: "1.0.0-0000084-9f4a6ca6",
                eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-PR-819-3-itest",
                watchdog_image_tag: "sam-0002530-db32f9dc",  # Adds cli-checker stderr logging
            },
            feature_flags+: {
            },
            # No legacy Flowsnake in Public Cloud
            version_mapping: {},
        },
        ### A very special phase 3 for IAD and ORD that preserves access to old versions used by CRE.
        ### TODO:  Remove when CRE is migrated to 0.12.2+
        "3-iad-ord": self["3"] {
            version_mapping+: {
                "0.10.0": 662,
                "0.12.0": 696,
                "0.12.1": 10001,
                "0.12.5": 10011,
            },
        },

        ### Release Phase minikube
        minikube: self["3"] {
            image_tags+: {
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
            },

            version_mapping: {
                minikube: "minikube",
            },
        },
    },

    ### Phase kingdom/estate mapping
    phase: (
        if flowsnakeconfig.is_minikube then
            "minikube"
        else if estate == "prd-data-flowsnake_test" then
            "1"
        else if estate == "prd-dev-flowsnake_iot_test" then
            "2-prd-dev"
        else if estate == "prd-data-flowsnake" then
            "2-prd-data"
        else if kingdom == "frf" then
            "2-frf"
        else if kingdom == "cdu" then
            "2-cdu"
        else if (kingdom == "iad" || kingdom == "ord") then
            "3-iad-ord"
        else if flowsnakeconfig.is_public_cloud then
            "3-pcl"
        else
            "3"
        ),

    # These are the images used by the templates
    # Only change when image name change from https://git.soma.salesforce.com/dva-transformation/flowsnake-platform
    cert_secretizer: flowsnakeconfig.strata_registry + "/flowsnake-cert-secretizer:" + $.per_phase[$.phase].image_tags.cert_secretizer_image_tag,
    es: flowsnakeconfig.strata_registry + "/flowsnake-elasticsearch:" + $.per_phase[$.phase].image_tags.es_image_tag,
    fleet_service: flowsnakeconfig.strata_registry + "/flowsnake-fleet-service:" + $.per_phase[$.phase].image_tags.fleetService_image_tag,
    event_exporter: flowsnakeconfig.strata_registry + "/flowsnake-event-exporter:" + $.per_phase[$.phase].image_tags.eventExporter_image_tag,
    test_data: flowsnakeconfig.strata_registry + "/flowsnake-test-data:" + $.per_phase[$.phase].image_tags.testData_image_tag,
    glok: flowsnakeconfig.strata_registry + "/flowsnake-kafka:" + $.per_phase[$.phase].image_tags.glok_image_tag,
    impersonation_proxy: flowsnakeconfig.strata_registry + "/flowsnake-kubernetes-impersonation-proxy:" + $.per_phase[$.phase].image_tags.impersonation_proxy_image_tag,
    ingress_controller_nginx: flowsnakeconfig.strata_registry + "/flowsnake-ingress-controller-nginx:" + $.per_phase[$.phase].image_tags.ingressControllerNginx_image_tag,
    ingress_default_backend: flowsnakeconfig.strata_registry + "/flowsnake-ingress-default-backend:" + $.per_phase[$.phase].image_tags.ingressDefaultBackend_image_tag,
    kibana: flowsnakeconfig.strata_registry + "/flowsnake-kibana:" + $.per_phase[$.phase].image_tags.kibana_image_tag,
    logloader: flowsnakeconfig.strata_registry + "/flowsnake-logloader:" + $.per_phase[$.phase].image_tags.logloader_image_tag,
    logstash: flowsnakeconfig.strata_registry + "/flowsnake-logstash:" + $.per_phase[$.phase].image_tags.logstash_image_tag,
    node_monitor: flowsnakeconfig.strata_registry + "/flowsnake-node-monitor:" + $.per_phase[$.phase].image_tags.nodeMonitor_image_tag,
    watchdog_canary: flowsnakeconfig.strata_registry + "/watchdog-canary:" + $.per_phase[$.phase].image_tags.watchdog_canary_image_tag,
    watchdog_spark_operator: flowsnakeconfig.strata_registry + "/flowsnake-spark-on-k8s-sample-apps:" + $.per_phase[$.phase].image_tags.watchdog_spark_operator_image_tag,
    docker_daemon_watchdog: flowsnakeconfig.strata_registry + "/docker-daemon-watchdog:" + $.per_phase[$.phase].image_tags.docker_daemon_watchdog_image_tag,
    zookeeper: flowsnakeconfig.strata_registry + "/flowsnake-zookeeper:" + $.per_phase[$.phase].image_tags.zookeeper_image_tag,
    madkub_injector: flowsnakeconfig.strata_registry + "/flowsnake-madkub-injector-webhook:" + $.per_phase[$.phase].image_tags.madkub_injector_image_tag,
    spark_operator: flowsnakeconfig.strata_registry + "/kubernetes-spark-operator-2.4.0-sfdc-0.0.1:" + $.per_phase[$.phase].image_tags.spark_operator_image_tag,

    feature_flags: $.per_phase[$.phase].feature_flags,
    # Convert to the format expected by std.manifestIni for generating Windows-style .ini files
    version_mapping: {
        main: $.per_phase[$.phase].version_mapping,
        sections: {},
    },

    # Non-Flowsnake images
    snapshoter: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.snapshoter_image_tag),
    snapshot_consumer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.snapshot_consumer_image_tag),
    deployer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.deployer_image_tag),
    watchdog: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.watchdog_image_tag),
    node_controller: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.node_controller_image_tag),
    madkub: if flowsnakeconfig.is_minikube then flowsnakeconfig.strata_registry + "/madkub:" + $.per_phase[$.phase].image_tags.madkub_image_tag else imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].image_tags.madkub_image_tag),
    beacon: flowsnakeconfig.registry + "/sfci/servicelibs/beacon:" + $.per_phase[$.phase].image_tags.beacon_image_tag,
    kubedns: flowsnakeconfig.strata_registry + "/k8s-dns-kube-dns:" + $.per_phase[$.phase].image_tags.kubedns_image_tag,
    kubednsmasq: flowsnakeconfig.strata_registry + "/k8s-dns-dnsmasq-nanny:" + $.per_phase[$.phase].image_tags.kubedns_image_tag,
    kubednssidecar: flowsnakeconfig.strata_registry + "/k8s-dns-sidecar:" + $.per_phase[$.phase].image_tags.kubedns_image_tag,
    # Used by synthetic-dns-check; possible future use for other config-map-script-based helper-pods
    jdk8_base: flowsnakeconfig.strata_registry + "/sfdc_centos7_jdk8:" + $.per_phase[$.phase].image_tags.jdk8_base_tag,

    prometheus_scraper: flowsnakeconfig.strata_registry + "/prome_for_k8s:" + $.per_phase[$.phase].image_tags.prometheus_funnel_image_tag,
    funnel_writer: flowsnakeconfig.strata_registry + "/funnel_writer:" + $.per_phase[$.phase].image_tags.prometheus_funnel_image_tag,

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
