local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local configs = import "config.jsonnet";
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
                watchdog_image_tag: "2722-a1231485debac6b17dfa76e7a1af01750e0f4f8b",  # 05/2019 image
                integration_test_tag: "22",
                hbase_integration_test_tag: "22",
                spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-operator-PR-40-5-itest",  # 10/2 image that bumps up client throttle
                prometheus_funnel_image_tag: "37",
            },
            feature_flags+: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                # --- flag A (Do not edit ... ---
                btrfs_watchdog_hard_reset: "",
                # --- flag B (these comments ... ---
                image_renames_and_canary_build_tags: "unverified",
                # --- flag C (and place only ... ---
                slb_ingress: "unverified",
                # --- flag D (one flag between ... ---
                # --- flag E (each pair. ... ---
                v1beta1_original: "",
                # --- flag F (Their only purpose ... ---
                watchdog_refactoring: "",
                # --- flag G (is to assist ... ---
                prometheus_funnel_update: "",
                # --- flag H (git's diff logic ... ---
                # --- flag I (to reduce the ---
                # --- flag J (likelihood of merge conflicts.) ---
                central_prometheus_forwarder: "試行中",
            },
            # prd-test offers legacy version mappings. Phase 2 does not, so cannot inherit from there.
            # Start with 2-prd-dev (which also have legacy version mappings),
            # and then any cusomizations just for this fleet.
            version_mapping: $.per_phase["2-prd-dev"].version_mapping {
            },
        },
        # Phase 2: Remaining PRD fleets and production canary fleets.
        # Only include new things not yet promoted to next phase. To promote, move line items to next phase.
        "2": self.prod {
            image_tags+: {
                integration_test_tag: "22",
                hbase_integration_test_tag: "22",
                prometheus_funnel_image_tag: "37",
            },
            feature_flags+: {
                # --- flag A (Do not edit ... ---
                # --- flag B (these comments ... ---
                # --- flag C (and place only ... ---
                # --- flag D (one flag between ... ---
                # --- flag E (each pair. ... ---
                # --- flag F (Their only purpose ... ---
                watchdog_refactoring: "",
                # --- flag G (is to assist ... ---
                # --- flag H (git's diff logic ... ---
                # --- flag I (to reduce the ---
                # --- flag J (likelihood of merge conflicts.) ---
                upcase_pki_kingdom: "",
            },
            version_mapping+: {
            },
        },
        # prd-dev: Exceptions vs the rest of phase 2 only
        "2-prd-dev": self["2"] {
            image_tags+: {
                spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-operator-PR-40-5-itest",  # 10/2 image that bumps up client throttle
                service_mesh_image_tag: "1.0.13",
            },
            feature_flags+: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
                btrfs_watchdog_hard_reset: "",  # Was promoted to prd-dev before phasing refactor
            },
            # prd-dev offers legacy version mappings. Phase 2 does not, so cannot inherit from there.
            # Start with iad-ord (which also have legacy version mappings),
            # then apply overrides from generic phase 2, and then any customizations just for this fleet.
            version_mapping: $.per_phase["iad-ord"].version_mapping + super.version_mapping + {
            },
        },
        # prd-data: Exceptions vs. the rest of phase 2 only
        "2-prd-data": self["2"] {
            image_tags+: {
                spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-operator-PR-40-5-itest",  # 10/2 image that bumps up client throttle
            },
            feature_flags+: {
                # Note: the *value* of the flags is ignored. jsonnet lacks array search, so we use a an object.
            },
            # prd-data offers legacy version mappings. Phase 2 does not, so cannot inherit from there.
            # Start with iad-ord (which also have legacy version mappings),
            # then apply overrides from generic phase 2, and then any cusomizations just for this fleet.
            version_mapping: $.per_phase["iad-ord"].version_mapping + super.version_mapping + {
            },
        },

        # Phase prod: Remaining production fleets.
        # This is the defacto "default" set of items.
        prod: {
            image_tags: {
                # Flowsnake v1 images
                beacon_image_tag: "853c4db9f14805018be6f5e7607ffe65b5648822",
                cert_secretizer_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                es_image_tag: "503",
                fleetService_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                glok_image_tag: "472",  # NOTE: THIS MUST NOT CHANGE. As of Aug 2018, this image is no longer built by the flowsnake-platform project.
                ingressControllerNginx_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                ingressDefaultBackend_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                kibana_image_tag: "345",
                logloader_image_tag: "468",
                logstash_image_tag: "468",
                testData_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                watchdog_canary_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                zookeeper_image_tag: "345",

                # Flowsnake v2 images
                impersonation_proxy_image_tag: "8-9ced7803391be70dd7dc41cd3211800cda818f50",  # exec's nginx for signal propagation
                spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-operator-PR-16-7-itest",  # 06/24 image with the augmented operator instrumentation
                # to remove
                watchdog_spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-sample-apps-PR-2-1-itest",
                integration_test_tag: "18",
                hbase_integration_test_tag: "20",
                kube_state_metrics_image_tag: "3",
                prometheus_funnel_image_tag: "36",
                spark_worker_23_hadoop_292_image_tag: "jenkins-dva-transformation-flowsnake-sample-apps-cre-hadoop-292-5-itest",

                # Fleet components including SAM components
                deployer_image_tag: "2653-de840aef94cedaeb0b971120b108b3570db4eb59",
                docker_daemon_watchdog_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                eventExporter_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                jdk8_base_tag: "33",
                kubedns_image_tag: "1.14.9",
                madkub_image_tag: "1.0.0-0000084-9f4a6ca6",  # Madkub server gets token for itself using host IP
                madkub_injector_image_tag: "13",
                service_mesh_image_tag: "1.0.5",
                service_injector_image_tag: "jenkins-dva-transformation-service-mesh-injector-webhook-PR-1-23-itest",
                node_controller_image_tag: "sam-0001970-a296421d",
                nodeMonitor_image_tag: "jenkins-dva-transformation-flowsnake-platform-master-781-itest",
                snapshot_consumer_image_tag: "2782-642a31c27d65c41109e7abe97ab07c984fe6385a",
                snapshoter_image_tag: "sam-0002052-bc0d9ea5",
                watchdog_image_tag: "2687-6c147b04d2d506c9fd591d50f400bd86c485b155",  # Add stdout/stderr to watchdog report email for cli-checker
            },
            feature_flags: {
                # After promoting a feature-flag to phase 4, please submit a follow-on PR to remove the flag and
                # associated conditional logic. That PR will not affect k8s-out, so you can self-approve it.

                # --- flag A (Do not edit ... ---
                # --- flag B (these comments ... ---
                # --- flag C (and place only ... ---
                # --- flag D (one flag between ... ---
                # --- flag E (each pair. ... ---
                # --- flag F (Their only purpose ... ---
                # --- flag G (is to assist ... ---
                # --- flag H (git's diff logic ... ---
                # --- flag I (to reduce the ---
                # --- flag J (likelihood of merge conflicts.) ---
            },
            version_mapping: {
                "0.12.5": "jenkins-dva-transformation-flowsnake-platform-master-781-itest",  # jenkins-dva-transformation-flowsnake-platform-master-781-itest contains MoFo estates and Kevin's 5xx fixes
                "0.12.5-hbase": "jenkins-dva-transformation-flowsnake-platform-hbase-init-fix-1-itest",
            },
        },
        # EMEA (Europe Middle East Africa): FRF, PAR
        # off-peak: 1pm-9pm PDT
        "prod-emea": self.prod {
            image_tags+: {
                            spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-operator-PR-40-5-itest",  # 10/2 image that bumps up client throttle
                        },
        },

        # NA (North America): DFW, IAD, IA2, ORD, PHX, PH2, YHU, YUL
        # off-peak: 6pm-4am PDT
        "prod-na": self.prod {
            image_tags+: {
                            spark_operator_image_tag: "jenkins-dva-transformation-spark-on-k8s-operator-PR-40-5-itest",  # 10/2 image that bumps up client throttle
                        },
        },

        # APAC (Asia Pacific): HND, UKB, CDU, SYD
        # off-peak: 6am-1pm PDT
        "prod-apac": self.prod {
        },


        iad: self["prod-na"] {
          version_mapping+: $.per_phase["iad-ord"].version_mapping {
          },
        },
        ord: self["prod-na"] {
          version_mapping+: $.per_phase["iad-ord"].version_mapping {
          },
        },
        dfw: self["prod-na"] {
        },
        ia2: self["prod-na"] {
        },
        phx: self["prod-na"] {
        },
        ph2: self["prod-na"] {
        },
        yhu: self["prod-na"] {
          version_mapping: {},  # No legacy Flowsnake in Public Cloud; therefore force empty verson_mapping
        },
        yul: self["prod-na"] {
          version_mapping: {},  # No legacy Flowsnake in Public Cloud; therefore force empty verson_mapping
        },

        frf: self["prod-emea"] {
          image_tags+: {
              integration_test_tag: "22",
              hbase_integration_test_tag: "22",
          },
          feature_flags+: {
              # --- flag A (Do not edit ... ---
              # --- flag B (these comments ... ---
              # --- flag C (and place only ... ---
              # --- flag D (one flag between ... ---
              # --- flag E (each pair. ... ---
              # --- flag F (Their only purpose ... ---
              watchdog_refactoring: "",
              # --- flag G (is to assist ... ---
              # --- flag H (git's diff logic ... ---
              # --- flag I (to reduce the ---
              # --- flag J (likelihood of merge conflicts.) ---
              upcase_pki_kingdom: "",
          },
        },
        par: self["prod-emea"] {
        },

        hnd: self["prod-apac"] {
        },
        ukb: self["prod-apac"] {
        },
        cdu: self["prod-apac"] {
          image_tags+: {
              integration_test_tag: "22",
              hbase_integration_test_tag: "22",
          },
          feature_flags+: {
              # --- flag A (Do not edit ... ---
              # --- flag B (these comments ... ---
              # --- flag C (and place only ... ---
              # --- flag D (one flag between ... ---
              # --- flag E (each pair. ... ---
              # --- flag F (Their only purpose ... ---
              watchdog_refactoring: "",
              # --- flag G (is to assist ... ---
              # --- flag H (git's diff logic ... ---
              # --- flag I (to reduce the ---
              # --- flag J (likelihood of merge conflicts.) ---
              upcase_pki_kingdom: "",
          },
          version_mapping: {},  # No legacy Flowsnake in Public Cloud; therefore force empty verson_mapping
        },
        syd: self["prod-apac"] {
          version_mapping: {},  # No legacy Flowsnake in Public Cloud; therefore force empty verson_mapping
        },

        ### Preserves access to old versions used by CRE. Also inherited by prd-data and prd-dev fleets.
        ### TODO: Remove when CRE is migrated to 0.12.2+ or Spark Operator
        "iad-ord": self["prod-na"] {
            version_mapping+: {
                "0.10.0": 662,
                "0.12.0": 696,
                "0.12.1": 10001,
                "0.12.5": 10011,
            },
        },

        ### Release Phase minikube
        minikube: self.prod {
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
        else if flowsnakeconfig.is_prod_fleet then
            kingdom
        else
            "prod"
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
    docker_daemon_watchdog: flowsnakeconfig.strata_registry + "/docker-daemon-watchdog:" + $.per_phase[$.phase].image_tags.docker_daemon_watchdog_image_tag,
    zookeeper: flowsnakeconfig.strata_registry + "/flowsnake-zookeeper:" + $.per_phase[$.phase].image_tags.zookeeper_image_tag,
    madkub_injector: flowsnakeconfig.strata_registry + "/flowsnake-madkub-injector-webhook:" + $.per_phase[$.phase].image_tags.madkub_injector_image_tag,
    service_mesh_injector: flowsnakeconfig.strata_registry + "/flowsnake-service-mesh-injector-webhook:" + $.per_phase[$.phase].image_tags.service_injector_image_tag,
    spark_operator: flowsnakeconfig.strata_registry + "/kubernetes-spark-operator-2.4.0-sfdc-0.0.1:" + $.per_phase[$.phase].image_tags.spark_operator_image_tag,
    spark_operator_watchdog_canary: flowsnakeconfig.strata_registry + "/flowsnake-spark-on-k8s-integration-test-runner:" + $.per_phase[$.phase].image_tags.integration_test_tag,
    hbase_watchdog_canary: flowsnakeconfig.strata_registry + "/flowsnake-spark-on-k8s-integration-test-runner:" + $.per_phase[$.phase].image_tags.hbase_integration_test_tag,
    basic_operator_integration: flowsnakeconfig.strata_registry + "/flowsnake-basic-operator-integration:" + $.per_phase[$.phase].image_tags.integration_test_tag,
    phoenix_spark_hbase_integration: flowsnakeconfig.strata_registry + "/flowsnake-phoenix-spark-hbase-integration:" + $.per_phase[$.phase].image_tags.hbase_integration_test_tag,
    kube_state_metrics: flowsnakeconfig.strata_registry + "/kube-state-metrics-sfdc-0.0.1:" + $.per_phase[$.phase].image_tags.kube_state_metrics_image_tag,
    spark_worker_23_hadoop_292: flowsnakeconfig.strata_registry + "/flowsnake-spark-worker_2.3.0-hadoop_2.9.2-cre:" + $.per_phase[$.phase].image_tags.spark_worker_23_hadoop_292_image_tag,
    # to remove V
    watchdog_spark_operator: flowsnakeconfig.strata_registry + "/flowsnake-spark-on-k8s-sample-apps:" + $.per_phase[$.phase].image_tags.watchdog_spark_operator_image_tag,
    spark_on_k8s_sample_apps: flowsnakeconfig.strata_registry + "/flowsnake-spark-on-k8s-sample-apps:" + $.per_phase[$.phase].image_tags.integration_test_tag,
    hbase_spark_on_k8s_sample_apps: flowsnakeconfig.strata_registry + "/flowsnake-spark-on-k8s-sample-apps:" + $.per_phase[$.phase].image_tags.hbase_integration_test_tag,

    feature_flags: $.per_phase[$.phase].feature_flags,
    # Convert to the format expected by std.manifestIni for generating Windows-style .ini files
    version_mapping: {
        main: $.per_phase[$.phase].version_mapping,
        sections: {},
    },

    # Non-Flowsnake images
    snapshoter: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.snapshoter_image_tag),
    snapshot_consumer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.snapshot_consumer_image_tag),
    // pseudo_kubeapi image comes from: https://git.soma.salesforce.com/dva-transformation/sam/commit/26d05939c8e5f467cc0799dc77d82196bc2411cb
    pseudo_kubeapi: imageFunc.do_override_for_non_pipeline_image($.overrides, "hypersam", "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/qcai/virtual-api:2019_08_06_26d0593"),
    dashboard: imageFunc.do_override_for_non_pipeline_image($.overrides, "dashboard", "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/d.smith/dashboard:webhook"),
    deployer: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.deployer_image_tag),
    watchdog: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.watchdog_image_tag),
    node_controller: imageFunc.do_override_based_on_tag($.overrides, "sam", "hypersam", $.per_phase[$.phase].image_tags.node_controller_image_tag),
    madkub: if flowsnakeconfig.is_minikube then flowsnakeconfig.strata_registry + "/madkub:" + $.per_phase[$.phase].image_tags.madkub_image_tag else imageFunc.do_override_based_on_tag($.overrides, "sam", "madkub", $.per_phase[$.phase].image_tags.madkub_image_tag),
    service_mesh: configs.registry + "/sfci/servicelibs/sherpa-envoy:" + $.per_phase[$.phase].image_tags.service_mesh_image_tag,
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
        "pr-build": [
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
           "flowsnake-zookeeper",
           "flowsnake-logstash",
           "flowsnake-hbase-init-container",
        ],
        # Aliases for pre-0.11.0 versions
        "0.9.10": self['__pre-spark-2.3'],
        "0.10.0": self['__pre-spark-2.3'],
        "0.12.5-hbase": self['pr-build'],
    },
}
