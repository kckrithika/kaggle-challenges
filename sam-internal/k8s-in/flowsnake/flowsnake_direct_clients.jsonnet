local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
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

        # ------------------------------------
        # ---------- PRD-data fleet ----------
        # ------------------------------------
        "prd-data-flowsnake": [
            {
                owner_name: "Wave ELT",
                namespace: "wave-elt",
                pki_namespace: "wave-elt",
                users: ["wave-elt.datapool", "wave-elt.datapool-test", "wave-elt.spark-engine"],
            },
        ],

        # ------------------------------------
        # ---------- PRD-test fleet ----------
        # ------------------------------------
        "prd-data-flowsnake_test": [
        ],

        # ------------------------------------
        # ---------- PRD-dev fleet ----------
        # ------------------------------------
        "prd-dev-flowsnake_iot_test": [
        ],
    },

    # Every estate gets flowsnake-watchdog for continuous synthetic testing
    # Every R&D estate gets flowsnake-test (for ad hoc deleveloper testing)

    clients_additional: [] +
    (if std.objectHas(flowsnake_images.feature_flags, "spark_operator") then [
        # Flowsnake ad hoc developer testing
        {
            owner_name: "Flowsnake",
            namespace: "flowsnake-test",  # Kubernetes namespaces cannot contain '_' characters
            pki_namespace: "flowsnake_test",  # https://git.soma.salesforce.com/Infrastructure-Security/GlobalRegistry/blob/82cdcf28a5c12df73f5d73cb6f214d516b9dd348/conf/namespace.json#L1940-L1947
            users: ["flowsnake_test.lorrin.nelson"],  # Get yourself a workstation cert and add it here. https://salesforce.quip.com/TkvaAbgSpYF4
        },
    ] else []) +
    # TODO: is_test check temporary until validated in prd-test
    (if flowsnake_config.is_r_and_d && std.objectHas(flowsnake_images.feature_flags, "spark_op_watchdog") then [
        # Flowsnake watchdog continuous synthetic testing of Spark operator
        {
            owner_name: "Flowsnake",
            namespace: "flowsnake-watchdog",  # Kubernetes namespaces cannot contain '_' characters
            pki_namespace: "flowsnake_test",  # https://git.soma.salesforce.com/Infrastructure-Security/GlobalRegistry/blob/82cdcf28a5c12df73f5d73cb6f214d516b9dd348/conf/namespace.json#L1940-L1947
            users: [],  # No external access required
        },
    ] else []),

    clients: (if std.objectHas(self.clients_per_estate, estate) then self.clients_per_estate[estate] else []) + self.clients_additional,

}
