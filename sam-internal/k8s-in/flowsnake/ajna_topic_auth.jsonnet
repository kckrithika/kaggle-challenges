local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_config = import "flowsnake_config.jsonnet";

if flowsnake_config.is_v1_enabled then {
    topic_grants: (if std.objectHas(self.topic_grants_map, kingdom + "/" + estate) then $.topic_grants_map[kingdom + "/" + estate] else error "No matching topic_grants entry: " + kingdom + "/" + estate),

    // Map from fleet (kingdom/estate) to map from LDAP group to list of Ajna topics.
    // Flowsnake environments in that fleet using a PKI Namespace that may be accessed by that LDAP group
    // may access those Ajna topics.
    // TODO: Move customers over to using tenant certs and direct access to their topics. See also https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000004vNlhIAE/view
   topic_grants_map: flowsnake_config.validate_kingdom_estate_fields({
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
                "sfdc.prod.dvasyslog__dfw.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__dfw.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__dfw.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__frf.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__frf.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__frf.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__iad.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__iad.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__iad.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__ord.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__ord.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__ord.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__par.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__par.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__par.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__phx.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__phx.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__phx.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__prd.ajna_local__network",
                "sfdc.prod.dvasyslog__prd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__prd.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__prd.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__ukb.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__ukb.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__ukb.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__hnd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__hnd.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__hnd.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__xrd.ajna_local__syslog.network",
                "sfdc.prod.dvasyslog__xrd.ajna_local__syslog.network.raw",
                "sfdc.prod.dvasyslog__xrd.ajna_local__syslog.device",
                "sfdc.prod.dvasyslog__dfw.ajna_local__trap",
                "sfdc.prod.dvasyslog__phx.ajna_local__trap",
                "sfdc.prod.dvasyslog__frf.ajna_local__trap",
                "sfdc.prod.dvasyslog__par.ajna_local__trap",
                "sfdc.prod.dvasyslog__iad.ajna_local__trap",
                "sfdc.prod.dvasyslog__ord.ajna_local__trap",
                "sfdc.prod.dvasyslog__hnd.ajna_local__trap",
                "sfdc.prod.dvasyslog__ukb.ajna_local__trap",
                "sfdc.prod.dvasyslog__prd.ajna_local__trap",
                "sfdc.prod.dvasyslog__xrd.ajna_local__trap",
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
        "frf/frf-flowsnake_prod": {
        },
        "par/par-flowsnake_prod": {
        },
        "dfw/dfw-flowsnake_prod": {
        },
        "ia2/ia2-flowsnake_prod": {
        },
        "ph2/ph2-flowsnake_prod": {
        },
        "hnd/hnd-flowsnake_prod": {
        },
        "ukb/ukb-flowsnake_prod": {
        },
        "yul/yul-flowsnake_prod": {
        },
        "yhu/yhu-flowsnake_prod": {
        },
        "syd/syd-flowsnake_prod": {
        },
        "cdu/cdu-flowsnake_prod": {
        },
    }),
} else "SKIP"
