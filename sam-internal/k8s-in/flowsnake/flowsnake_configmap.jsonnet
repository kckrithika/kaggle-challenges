local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    auth_groups: (if std.objectHas(self.auth_groups_map, kingdom + "/" + estate) then $.auth_groups_map[kingdom + "/" + estate] else error "No matching auth group name: " + kingdom + "/" + estate),
    topic_grants: (if std.objectHas(self.topic_grants_map, kingdom + "/" + estate) then $.topic_grants_map[kingdom + "/" + estate] else error "No matching topic grants name: " + kingdom + "/" + estate),
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
            "DSS_FLOWSNAKE_SERVICE"
        ],
        "prd/prd-data-flowsnake_test": [
            "Flowsnake_Ops_Platform"
        ],
        "prd/prd-dev-flowsnake_iot_test": [
            "Flowsnake_Ops_Platform",
            "IoT-RM-Flowsnake",
            "CRE_AD"
        ],
    },
    topic_grants_map: {
        "prd/prd-data-flowsnake": {
            "alerting_flowsnake": [
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
                "sfdc.prod.dvasyslog__chx.ajna_local__trap"
            ],
            "Security-Analytics": [
                "sfdc.prod.flowsnake__prd.ajna_agg__logs.dffpg",
                "sfdc.prod.securityanalytics__prd.ajna_agg__logs.egress"
            ],
            "Flowsnake_Ops_Platform": [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs"
            ]
        },
        "prd/prd-data-flowsnake_test": {
            "Flowsnake_Ops_Platform": [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs"
            ]
        },
        "prd/prd-dev-flowsnake_iot_test": {
            "Flowsnake_Ops_Platform": [
                "sfdc.test.flowsnake__prd.ajna_local__logs",
                "sfdc.prod.flowsnake__prd.ajna_local__logs"
            ]
        },
    },
    samcontroldeployer: {
        "ca-file": "/etc/pki_service/ca/cabundle.pem",
        "cert-file": "/etc/pki_service/platform/platform-client/certificates/platform-client.pem",
        "delete-orphans": true,
        "disable-rollback": true,
        "disable-security-check": true,
        "dry-run": false,
        "email": true,
        "email-delay": 0,
        "funnelEndpoint": "ajna0-funnel1-0-prd.data.sfdc.net:80",
        "key-file": "/etc/pki_service/platform/platform-client/keys/platform-client-key.pem",
        "max-resource-time": 300000000000,
        "poll-delay": 30000000000,
        "recipient": "flowsnake@salesforce.com",
        "resource-cooldown": 15000000000,
        "resource-progression-timeout": 120000000000,
        "resources-to-skip": [
          "_flowsnake-sdn-secret.yaml",
          "samcontrol-deployer.yaml",
          "watchdog-common.yaml",
          "watchdog-etcd.yaml",
          "watchdog-master.yaml",
          "watchdog-node.yaml",
          "watchdog-pod.yaml"
        ],
        "sender": "flowsnake@salesforce.com",
        "smtp-server": "rd1-mta1-4-sfm.ops.sfdc.net:25",
        "tnrp-endpoint": "https://ops0-piperepo1-0-prd.data.sfdc.net/tnrp/content_repo/0/archive",
        "override-control-estate": "/prd/prd-sam",
        "orphan-namespace": "flowsnake"
    }
}
