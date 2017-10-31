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
            "Lightning_Instrumentation"
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
}
