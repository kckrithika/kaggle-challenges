local flowsnakeimage = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local samconfig = import "config.jsonnet";
{
    auth_groups: (if std.objectHas(self.auth_groups_map, kingdom + "/" + estate) then $.auth_groups_map[kingdom + "/" + estate] else error "No matching auth group name: " + kingdom + "/" + estate),
    topic_grants: (if std.objectHas(self.topic_grants_map, kingdom + "/" + estate) then $.topic_grants_map[kingdom + "/" + estate] else error "No matching topic grants name: " + kingdom + "/" + estate),
    maddog_namespace: (if std.objectHas(self.maddog_namespace_map, kingdom + "/" + estate) then $.maddog_namespace_map[kingdom + "/" + estate] else error "No matching maddog namespace map: " + kingdom + "/" + estate),
    auth_groups_map: {
        "prd/prd-data-flowsnake": [
            "Flowsnake_Ops_Platform",
            "Security-Analytics",
            "alerting_flowsnake",
            "dbvisibility",
            "IoT-RM-Flowsnake",
            "FS_Rackbot",
            "MCeventing",
            "Analytics Service Ownership",
            "CRE_AD",
            "Lightning_Instrumentation",
            "Analytics-DataPool",
            "DSS_FLOWSNAKE_SERVICE",
            "ServiceProtection",
            "collection_flowsnake",
            "key_infrastructure",
        ],
        "prd/prd-data-flowsnake_test": [
            "Flowsnake_Ops_Platform",
        ],
        "prd/prd-dev-flowsnake_iot_test": [
            "Flowsnake_Ops_Platform",
            "IoT-RM-Flowsnake",
            "CRE_AD",
            "Analytics-DataPool",
        ],
        "prd/prd-minikube-small-flowsnake": [
            "Flowsnake_Ops_Platform",
        ],
        "prd/prd-minikube-big-flowsnake": [
            "Flowsnake_Ops_Platform",
        ],
        "iad/iad-flowsnake_prod": [
        ],
        "ord/ord-flowsnake_prod": [
        ],
        "phx/phx-flowsnake_prod": [
        ],
    },
    topic_grants_map: {
        "prd/prd-data-flowsnake": {
            alerting_flowsnake: [
                "com.salesforce.prod.dva.alert",
                "com.salesforce.test.dva.alert",
                "sfdc.test.dvasyslog__chi.ajna_local__trap",
                "sfdc.test.dvasyslog__was.ajna_local__trap",
                "sfdc.test.dvasyslog__lon.ajna_local__trap",
                "sfdc.test.dvasyslog__tyo.ajna_local__trap",
                "sfdc.test.dvasyslog__dfw.ajna_local__trap",
                "sfdc.test.dvasyslog__phx.ajna_local__trap",
                "sfdc.test.dvasyslog__frf.ajna_local__trap",
                "sfdc.test.dvasyslog__par.ajna_local__trap",
                "sfdc.test.dvasyslog__iad.ajna_local__trap",
                "sfdc.test.dvasyslog__ord.ajna_local__trap",
                "sfdc.test.dvasyslog__yhu.ajna_local__trap",
                "sfdc.test.dvasyslog__yul.ajna_local__trap",
                "sfdc.test.dvasyslog__cdu.ajna_local__trap",
                "sfdc.test.dvasyslog__syd.ajna_local__trap",
                "sfdc.test.dvasyslog__hnd.ajna_local__trap",
                "sfdc.test.dvasyslog__ukb.ajna_local__trap",
                "sfdc.test.dvasyslog__prd.ajna_local__trap",
                "sfdc.prod.dvasyslog__chi.ajna_local__trap",
                "sfdc.prod.dvasyslog__was.ajna_local__trap",
                "sfdc.prod.dvasyslog__lon.ajna_local__trap",
                "sfdc.prod.dvasyslog__tyo.ajna_local__trap",
                "sfdc.prod.dvasyslog__dfw.ajna_local__trap",
                "sfdc.prod.dvasyslog__phx.ajna_local__trap",
                "sfdc.prod.dvasyslog__frf.ajna_local__trap",
                "sfdc.prod.dvasyslog__par.ajna_local__trap",
                "sfdc.prod.dvasyslog__iad.ajna_local__trap",
                "sfdc.prod.dvasyslog__ord.ajna_local__trap",
                "sfdc.prod.dvasyslog__yhu.ajna_local__trap",
                "sfdc.prod.dvasyslog__yul.ajna_local__trap",
                "sfdc.prod.dvasyslog__cdu.ajna_local__trap",
                "sfdc.prod.dvasyslog__syd.ajna_local__trap",
                "sfdc.prod.dvasyslog__hnd.ajna_local__trap",
                "sfdc.prod.dvasyslog__ukb.ajna_local__trap",
                "sfdc.prod.dvasyslog__prd.ajna_local__trap",
                "sfdc.prod.dvasyslog__wax.ajna-wax-spx__trap",
                "sfdc.prod.dvasyslog__chx.ajna_local__trap",
                "sfdc.test.dvasyslog__chi.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__was.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__lon.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__tyo.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__dfw.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__phx.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__frf.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__par.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__iad.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__ord.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__yhu.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__yul.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__cdu.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__syd.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__hnd.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__ukb.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__prd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__chi.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__was.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__lon.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__tyo.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__dfw.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__phx.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__frf.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__par.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__iad.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__ord.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__yhu.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__yul.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__cdu.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__syd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__hnd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__ukb.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__prd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__chx.ajna-chx-spx__trap",
                "sfdc.prod.dvasyslog__wax.ajna_local__trap",
                "sfdc.prod.dvasyslog__chx.ajna_local__trap",
            ],
            "Security-Analytics": [
                "sfdc.prod.flowsnake__prd.ajna_agg__logs.dffpg",
                "sfdc.prod.securityanalytics__prd.ajna_agg__logs.egress",
            ],
            Flowsnake_Ops_Platform: [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs",
            ],
            collection_flowsnake: [
                "sfdc.test.dvasyslog__dfw.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__dfw.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__dfw.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__dfw.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__dfw.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__frf.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__frf.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__frf.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__frf.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__frf.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__iad.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__iad.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__iad.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__iad.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__iad.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__ord.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__ord.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__ord.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__ord.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__ord.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__par.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__par.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__par.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__par.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__par.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__phx.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__phx.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__phx.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__phx.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__phx.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__prd.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__prd.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__prd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__prd.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__prd.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__ukb.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__ukb.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__ukb.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__ukb.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__ukb.ajna_local__syslog.device",
                "sfdc.test.dvasyslog__hnd.ajna_local__syslog.network",
                "sfdc.test.dvasyslog__hnd.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__hnd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__hnd.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__hnd.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__dfw.ajna_local__trap",
                "sfdc.prod.dvasyslog__phx.ajna_local__trap",
                "sfdc.prod.dvasyslog__frf.ajna_local__trap",
                "sfdc.prod.dvasyslog__par.ajna_local__trap",
                "sfdc.prod.dvasyslog__iad.ajna_local__trap",
                "sfdc.prod.dvasyslog__ord.ajna_local__trap",
                "sfdc.prod.dvasyslog__hnd.ajna_local__trap",
                "sfdc.prod.dvasyslog__ukb.ajna_local__trap",
                "sfdc.prod.dvasyslog__prd.ajna_local__trap",
            ],
        },
        "prd/prd-data-flowsnake_test": {
            Flowsnake_Ops_Platform: [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs",
            ],
        },
        "prd/prd-dev-flowsnake_iot_test": {
            Flowsnake_Ops_Platform: [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs",
            ],
        },
        "prd/prd-minikube-small-flowsnake": {
            Flowsnake_Ops_Platform: [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs",
            ],
        },
        "prd/prd-minikube-big-flowsnake": {
            Flowsnake_Ops_Platform: [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs",
            ],
        },
        "iad/iad-flowsnake_prod": {
        },
        "ord/ord-flowsnake_prod": {
        },
        "phx/phx-flowsnake_prod": {
        },
    },
        //TODO: This structure is bogus. Need to specify LDAP and PKI principals for each namespace.
    maddog_namespace_map: {
      "prd/prd-data-flowsnake": {
          flowsnake: "Flowsnake_Ops_Platform",
      },
      "prd/prd-data-flowsnake_test": {
          flowsnake: "Flowsnake_Ops_Platform",
      },
      "prd/prd-dev-flowsnake_iot_test": {
          flowsnake: "Flowsnake_Ops_Platform",
      },
        //TODO: In prod data centers, let the certs on the host act as administrators.
      "iad/iad-flowsnake_prod": {
      },
      "ord/ord-flowsnake_prod": {
      },
      "phx/phx-flowsnake_prod": {
      },
    },
    samcontroldeployer: {
        email: true,
        "email-delay": 0,
        "delete-orphans": false,
        "disable-rollback": true,
        "disable-security-check": true,
        "override-control-estate": "/" + kingdom + "/" + kingdom + "-sam",
        "orphan-namespaces": "flowsnake",
        funnelEndpoint: flowsnakeconfig.funnel_vip_and_port,
        "max-resource-time": 300000000000,
        "poll-delay": 30000000000,
        recipient: "flowsnake@salesforce.com",
        "resource-cooldown": 15000000000,
        "resource-progression-timeout": 120000000000,
        sender: "flowsnake@salesforce.com",
        "smtp-server": samconfig.smtpServer,
        "tnrp-endpoint": samconfig.tnrpArchiveEndpoint,
        "ca-file": flowsnakeconfig.host_ca_cert_path,
        "cert-file": flowsnakeconfig.host_platform_client_cert_path,
        "key-file": flowsnakeconfig.host_platform_client_key_path,
        "dry-run": false,
        "resources-to-skip": [
            // always skip this, should never get deployed by auto-deployer, sdn-secret-agent will read this file and deploy.
            "_flowsnake-sdn-secret.yaml",
        ] +
        (if !flowsnakeconfig.sdn_enabled then [
            "sdn-bird.yaml",
            "sdn-cleanup.yaml",
            "sdn-hairpin-setter.yaml",
            "sdn-peering-agent.yaml",
            "sdn-ping-watchdog.yaml",
            "sdn-route-watchdog.yaml",
            "sdn-secret-agent.yaml",
            "sdn-vault-agent.yaml",
        ] else []) +
        (if estate == "prd-data-flowsnake" || estate == "prd-dev-flowsnake_iot_test" then [
            //TODO: re-enable Autodeployer self-updates in all estates
            "samcontrol-deployer.yaml",
        ] else []) +
        (if flowsnakeconfig.deepsea_enabled then [
            // Must skip (and manually deploy) because AutoDeployer does not support Endpoints resources at the moment.
            // WI to change deepsea setup to not require the endpoint: https://gus.my.salesforce.com/a07B0000004lMMSIA2
            "deepsea-kdc-endpoints.yaml",
        ] else [
        ]),
    },
    watchdog_config: {
        "deployer-funnelEndpoint": flowsnakeconfig.funnel_vip_and_port,
        "deployer-imageName": flowsnakeimage.deployer,
        "deployer-rcImtEndpoint": samconfig.rcImtEndpoint,
        "deployer-recipient": "flowsnake@salesforce.com",
        "deployer-sender": "flowsnake@salesforce.com",
        "deployer-smtpServer": samconfig.smtpServer,
        deploymentNamespacePrefixWhitelist: "flowsnake",
        "email-subject-prefix": "FLOWSNAKEWD",
        enableMaddogCertChecks: true,
        enableStatefulChecks: true,
        enableStatefulPVChecks: true,
        funnelEndpoint: flowsnakeconfig.funnel_vip_and_port,
        imageName: flowsnakeimage.watchdog,
        kubeResourceNamespacePrefixBlacklist: "sam-watchdog",
        kubeResourceNamespacePrefixWhitelist: "sam-system,flowsnake",
        maxPVCAge: 420000000000,
        maxUptimeSampleSize: 5,
        maxdeploymentduration: 420000000000,
        monitoredProcesses: {
          "dockerd.*docker-bootstrap": "age.dockerbootstrap",
          "dockerd.*docker.sock": "age.dockermain",
          "hyperkube.*apiserver": "age.kubeapiserver",
          "hyperkube.*controller-manager": "age.kubecontrollermanager",
          "hyperkube.*kubelet": "age.kubelet",
          "hyperkube.*proxy": "age.kubeproxy",
          "hyperkube.*scheduler": "age.kubescheduler",
        },
        publishAlertsToKafka: false,
        publishAllReportsToKafka: false,
        rcImtEndpoint: samconfig.rcImtEndpoint,
        recipient: "flowsnake@salesforce.com",
        sdpEndpoint: "http://localhost:39999",
        sender: "flowsnake@salesforce.com",
        smtpServer: samconfig.smtpServer,
        syntheticPVRetrytimeout: 420000000000,
        syntheticretrytimeout: 420000000000,
        tlsEnabled: true,
    } +
    if estate == "prd-data-flowsnake_test" then {
        caFile: "/etc/pki_service/ca/cabundle.pem",
        certFile: "/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
        keyFile: "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
    } else {
        caFile: "/data/certs/ca.crt",
        certFile: "/data/certs/hostcert.crt",
        keyFile: "/data/certs/hostcert.key",
    },
}
