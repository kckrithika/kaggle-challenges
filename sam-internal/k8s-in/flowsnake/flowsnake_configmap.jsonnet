local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
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
    },
    maddog_namespace_map: {
      "prd/prd-data-flowsnake": {
          samapp: "Flowsnake_Ops_Platform",
      },
      "prd/prd-data-flowsnake_test": {
          samapp: "Flowsnake_Ops_Platform",
      },
      "prd/prd-dev-flowsnake_iot_test": {
          samapp: "Flowsnake_Ops_Platform",
      },
      "prd/prd-minikube-small-flowsnake": {
          samapp: "Flowsnake_Ops_Platform",
      },
      "prd/prd-minikube-big-flowsnake": {
          samapp: "Flowsnake_Ops_Platform",
      },
    },
    samcontroldeployer: {
        email: true,
        "email-delay": 0,
        "delete-orphans": false,
        "disable-rollback": true,
        "disable-security-check": true,
        "override-control-estate": "/prd/prd-sam",
        "orphan-namespaces": "flowsnake",
        funnelEndpoint: "ajna0-funnel1-0-prd.data.sfdc.net:80",
        "max-resource-time": 300000000000,
        "poll-delay": 30000000000,
        recipient: "flowsnake@salesforce.com",
        "resource-cooldown": 15000000000,
        "resource-progression-timeout": 120000000000,
        sender: "flowsnake@salesforce.com",
        "smtp-server": "rd1-mta1-4-sfm.ops.sfdc.net:25",
        "tnrp-endpoint": "https://ops0-piperepo1-0-prd.data.sfdc.net/tnrp/content_repo/0/archive",
    } +
    if estate == "prd-data-flowsnake_test" then
    {
        "ca-file": "/etc/pki_service/ca/cabundle.pem",
        "cert-file": "/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
        "dry-run": false,
        "key-file": "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
        "resources-to-skip": [
          "samcontrol-deployer.yaml",
          "_flowsnake-sdn-secret.yaml",
        ],
    }
    else {
        "ca-file": "/data/certs/ca.crt",
        "cert-file": "/data/certs/hostcert.crt",
        "dry-run": false,
        "key-file": "/data/certs/hostcert.key",
        "resources-to-skip": [
          "sdn-bird.yaml",
          "sdn-cleanup.yaml",
          "sdn-hairpin-setter.yaml",
          "sdn-peering-agent.yaml",
          "sdn-ping-watchdog.yaml",
          "sdn-route-watchdog.yaml",
          "sdn-secret-agent.yaml",
          "sdn-vault-agent.yaml",
          "_flowsnake-sdn-secret.yaml",
          "samcontrol-deployer.yaml",
          "deepsea-kdc-svc.yaml",
        ],
    },
    watchdog_config: {
        "deployer-funnelEndpoint": "ajna0-funnel1-0-prd.data.sfdc.net:80",
        "deployer-imageName": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jinxing.wang/hypersam:20180123_112004.cbc44617.dirty.jinxingwang-wsm",
        "deployer-rcImtEndpoint": "https://reportcollector-prd.data.sfdc.net:18443/v1/bark",
        "deployer-recipient": "flowsnake@salesforce.com",
        "deployer-sender": "flowsnake@salesforce.com",
        "deployer-smtpServer": "rd1-mta1-4-sfm.ops.sfdc.net:25",
        deploymentNamespacePrefixWhitelist: "flowsnake",
        "email-subject-prefix": "FLOWSNAKEWD",
        enableMaddogCertChecks: true,
        enableStatefulChecks: true,
        enableStatefulPVChecks: true,
        funnelEndpoint: "ajna0-funnel1-0-prd.data.sfdc.net:80",
        imageName: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/jinxing.wang/hypersam:20180123_112004.cbc44617.dirty.jinxingwang-wsm",
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
        rcImtEndpoint: "https://reportcollector-prd.data.sfdc.net:18443/v1/bark",
        recipient: "flowsnake@salesforce.com",
        sdpEndpoint: "http://localhost:39999",
        sender: "flowsnake@salesforce.com",
        smtpServer: "rd1-mta1-4-sfm.ops.sfdc.net:25",
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
