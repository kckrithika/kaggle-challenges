local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    auth_namespaces: (if std.objectHas(self.auth_namespaces_data, kingdom + "/" + estate) then $.auth_namespaces_data[kingdom + "/" + estate] else error "No matching auth_namespaces entry: " + kingdom + "/" + estate),

    // Map from fleet (kingdom/estate) to list of PKI namespaces and who is permitted to create Flowsnake environments
    // with that namespace in that fleet.
    // (Where "who" is identified by client certs for mTLS or LDAP group membership for Basic Auth)
    auth_namespaces_data: {
      "prd/prd-data-flowsnake": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
            authorizedClientCerts: ["flowsnake_master"],
        },
        {
            namespace: "alerting_snmp",
            authorizedLdapGroups: ["alerting_flowsnake"],
            authorizedClientCerts: [],
        },
        {
            namespace: "sec-einstein-deepsea",
            authorizedLdapGroups: ["security-analytics"],
            authorizedClientCerts: [],
        },
        {
            namespace: "collection_device_data_mon",
            authorizedLdapGroups: ["collection_flowsnake"],
            authorizedClientCerts: [],
        },
        {
            namespace: "search_dlc",
            authorizedLdapGroups: ["search_dlc"],
            authorizedClientCerts: [],
        },
        {
            namespace: "universal-search",
            authorizedLdapGroups: ["universal-search"],
            authorizedClientCerts: ["universal-search.universal-search"],
        },
        {
            namespace: "sayonara-applogs",
            authorizedLdapGroups: ["Sayonara-Flowsnake"],
            authorizedClientCerts: [],
        },
        {
            namespace: "edge_intelligence",
            authorizedLdapGroups: ["edge_intelligence"],
            authorizedClientCerts: [],
        },
        {
            namespace: "database-heimdall",
            authorizedLdapGroups: ["dbvisibility"],
            authorizedClientCerts: [],
        },
        {
            namespace: "flowsnake_test",
            authorizedLdapGroups: ["Flowsnake_Platform"],
            authorizedClientCerts: ["flowsnake_test"],
        },
        {
            namespace: "einstein_analytics_discovery_monitoring",
            authorizedLdapGroups: ["Analytics Service Ownership"],
            authorizedClientCerts: [],
        },
      ],
      "prd/prd-data-flowsnake_test": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
            authorizedClientCerts: ["flowsnake_master_test"],
        },
        {
            namespace: "flowsnake_test",
            authorizedLdapGroups: ["Flowsnake_Platform"],
            authorizedClientCerts: ["flowsnake_test"],
        },
      ],
      "prd/prd-dev-flowsnake_iot_test": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
            authorizedClientCerts: ["flowsnake_master_iot_test"],
        },
        {
            namespace: "flowsnake_test",
            authorizedLdapGroups: ["Flowsnake_Platform"],
            authorizedClientCerts: ["flowsnake_test"],
        },
        {
            namespace: "retail-cre",
            authorizedLdapGroups: ["CRE_AD"],
            authorizedClientCerts: ["retail-cre.cre-control-plane-ccp-func", "retail-cre.cre-control-plane-ccp-perf", "retail-cre.cre-control-plane-ccp-dev"],
        },
        {
            namespace: "universal-search",
            authorizedLdapGroups: ["universal-search"],
            authorizedClientCerts: ["universal-search.universal-search"],
        },
        {
            namespace: "iot",
            authorizedLdapGroups: ["IoT-RM-Flowsnake"],
            authorizedClientCerts: ["iot.provisioning", "iot.provisioning-ftest", "iot.provisioning-provisioningtest"],
        },
        {
            namespace: "wave-elt",
            authorizedLdapGroups: ["Analytics-DataPool"],
            authorizedClientCerts: ["wave-elt.datapool", "wave-elt.datapool-test1", "wave-elt.datapool-test2", "wave-elt.datapool-steelthread"],
        },
      ],
      "prd/prd-minikube-small-flowsnake": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake.minikube"],
        },
      ],
      "prd/prd-minikube-big-flowsnake": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: ["Flowsnake_Ops_Platform"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake.minikube"],
        },
      ],
      "iad/iad-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake_test"],
        },
        {
            namespace: "retail-cre",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["retail-cre.cre-control-plane"],
        },
        {
            namespace: "wave-elt",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["wave-elt.datapool"],
        },
        {
            namespace: "iot",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["iot.provisioning"],
        },
      ],
      "ord/ord-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake_test"],
        },
        {
            namespace: "retail-cre",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["retail-cre.cre-control-plane"],
        },
        {
            namespace: "wave-elt",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["wave-elt.datapool"],
        },
        {
            namespace: "iot",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["iot.provisioning"],
        },
      ],
      "phx/phx-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake_test"],
        },
      ],
      "frf/frf-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake_test"],
        },
      ],
      "par/par-flowsnake_prod": [
        {
            namespace: "flowsnake",
            authorizedLdapGroups: [],
            authorizedClientCerts: ["flowsnake_master_prod"],
        },
        {
            namespace: "flowsnake_test",
            authorizedClientCerts: ["flowsnake_test"],
        },
      ],
    },
}
