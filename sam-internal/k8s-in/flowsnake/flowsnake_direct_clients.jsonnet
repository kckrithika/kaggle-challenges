local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");

{
    # add new Spark-on-kubernetes clients to this object.
    clients_per_estate: {
        # Maps estates to list of clients authorized to use that estate.
        # {
        #     owner_name: "Owner Team", # Human-readable
        #     namespace: "some_client_namespace", # Kubernetes namespace
        #     pki-namespace: "some_pki_namespace", # Used to generate OU fields on client certs per https://git.soma.salesforce.com/dva-transformation/madkub-injector-webhook/#behavior-and-user-configuration
        #     users: ["clientrole.client_app1", "clientrole.client_app2"], # client OUs which may access namespace
        #     quota: { # Quota support not yet implemented
        #         cpu: 1000,
        #         pods: 200,
        #         memory: "20Gi"
        #         [...etc]
        #     }
        # },
        "prd-data-flowsnake": [
            {
                owner_name: "Wave ELT",
                namespace: "wave-elt",
                pki_namespace: "wave-elt",
                users: ["wave-elt.datapool", "wave-elt.datapool-test", "flowsnake.lorrin-impersonation-test", "wave-elt.spark-engine"],
            },
        ],
        "prd-data-flowsnake_test": [
            # Flowsnake adhoc developer testing
            {
                owner_name: "Flowsnake",
                namespace: "flowsnake_test",
                pki_namespace: "flowsnake_test",
                users: ["flowsnake_test.lorrin.nelson"],
            },
        ],
    },

    clients: if std.objectHas(self.clients_per_estate, estate) then self.clients_per_estate[estate] else [],

}
