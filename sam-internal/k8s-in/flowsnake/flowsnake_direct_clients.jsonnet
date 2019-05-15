local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local watchdog = import "watchdog.jsonnet";
local wave_elt_production = {
        owner_name: "Wave ELT",
        namespace: "wave-elt",
        pki_namespace: "wave-elt",
        users: ["wave-elt.datapool"],
};

{
    # add new Spark-on-kubernetes clients to this object.
    clients_per_estate: {
        # Maps estates to list of clients authorized to use that estate.
        # {
        #     owner_name: "Owner Team", # Human-readable
        #     namespace: "some_client_namespace", # Kubernetes namespace
        #     pki-namespace: "some_pki_namespace", # Used to generate OU fields on client certs per https://git.soma.salesforce.com/dva-transformation/madkub-injector-webhook/#behavior-and-user-configuration
        #     users: ["clientrole.client_app1", "clientrole.client_app2"], # client OUs which may access namespace
        #     quota: {
        #         cpu: 1000,
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
                # --------
                # Don't use quota until we get to k8s 1.14
                # quota: {
                #     memory: "100Gi",
                #     cpu: "40",
                # },
                # --------
            },
            {
                owner_name: "Universal Search",
                namespace: "universal-search",
                pki_namespace: "universal-search",
                users: [
                    "universal-search.universal-search",
                    "universal-search.athrogmorton",
                    "universal-search.irahim",
                ],
            },
        ],

        # ------------------------------------
        # ---------- PRD-test fleet ----------
        # ------------------------------------
        "prd-data-flowsnake_test": [
            {
                owner_name: "Carl - Testing",
                namespace: "carl-spark-test",
                pki_namespace: "flowsnake_test",
                users: ["cmeister-ltm.internal.salesforce.com", "flowsnake_test.cmeister"],
            },
            {
                owner_name: "Kevin - Testing",
                namespace: "kh-spark-test",
                pki_namespace: "flowsnake_test",
                users: ["khogeland-ltm.internal.salesforce.com", "flowsnake_test.khogeland"],
            },
        ],

        # ------------------------------------
        # ---------- PRD-dev fleet -----------
        # ------------------------------------
        "prd-dev-flowsnake_iot_test": [
        ],

        # -------------------------------
        # ---------- DFW fleet ----------
        # -------------------------------
        "dfw-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- FRF fleet ----------
        # -------------------------------
        "frf-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- HND fleet ----------
        # -------------------------------
        "hnd-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- IA2 fleet ----------
        # -------------------------------
        "ia2-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- IAD fleet ----------
        # -------------------------------
        "iad-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- ORD fleet ----------
        # -------------------------------
        "ord-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- PAR fleet ----------
        # -------------------------------
        "par-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- PH2 fleet ----------
        # -------------------------------
        "ph2-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- PHX fleet ----------
        # -------------------------------
        "phx-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- UKB fleet ----------
        # -------------------------------
        "ukb-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- YUL fleet (PCL) ----
        # -------------------------------
        "yul-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- YHU fleet (PCL) ----
        # -------------------------------
        "yhu-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- SYD fleet (PCL) ----
        # -------------------------------
        "syd-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- CDU fleet (PCL) ----
        # -------------------------------
        "cdu-flowsnake_prod": [wave_elt_production],

    },

    # Every estate gets flowsnake-watchdog for continuous synthetic testing
    # Every R&D estate gets flowsnake-test (for ad hoc deleveloper testing)

    clients_additional: [] +
    (if flowsnake_config.is_r_and_d then [
        # Flowsnake ad hoc developer testing
        {
            owner_name: "Flowsnake",
            namespace: "flowsnake-test",  # Kubernetes namespaces cannot contain '_' characters
            pki_namespace: "flowsnake_test",  # https://git.soma.salesforce.com/Infrastructure-Security/GlobalRegistry/blob/82cdcf28a5c12df73f5d73cb6f214d516b9dd348/conf/namespace.json#L1940-L1947
            users: [
                "flowsnake_test.lorrin.nelson",
                "flowsnake_test.s.sun",
            ],  # Get yourself a workstation cert and add it here. https://salesforce.quip.com/TkvaAbgSpYF4
        },
    ] else []) +
    (if watchdog.watchdog_enabled then [
        # Flowsnake watchdog continuous synthetic testing of Spark operator
        {
            owner_name: "Flowsnake",
            namespace: "flowsnake-watchdog",  # Kubernetes namespaces cannot contain '_' characters
            pki_namespace: "flowsnake_test",  # https://git.soma.salesforce.com/Infrastructure-Security/GlobalRegistry/blob/82cdcf28a5c12df73f5d73cb6f214d516b9dd348/conf/namespace.json#L1940-L1947
            users: ["flowsnake_test.flowsnake-watchdog"],  # For watchdogs that want to test impersonation proxy (i.e. want to use a cert rather than a service account token to create resources in flowsnake-watchdog namespace)
        },
    ] else []) +
    (if flowsnake_config.ci_resources_enabled then [
        # For CI integration testing during Strata builds
        # See explanatory documentation in templates/test/strata-integration-tests.jsonnet
        {
            owner_name: "Flowsnake Team - Strata CI Integration",
            namespace: "flowsnake-ci-tests",
            pki_namespace: "flowsnake_test",
            users: ["flowsnake_test.flowsnake-ci-test"],
        },
    ] else []),

    clients: (if std.objectHas(self.clients_per_estate, estate) then self.clients_per_estate[estate] else []) + self.clients_additional,

}
