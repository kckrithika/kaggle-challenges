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

local cre_production = {
        owner_name: "CRE",
        namespace: "retail-cre",
        pki_namespace: "retail-cre",
        users: ["retail-cre.cre-control-plane"],
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
                users: ["wave-elt.datapool", "wave-elt.datapool-test", "wave-elt.spark-engine", "wave-elt.jobcontroller-master", "wave-elt.jobcontroller-release"],
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
            {
                owner_name: "Ramya - Testing",
                namespace: "ramya-spark-test",
                pki_namespace: "flowsnake_test",
                users: ["flowsnake_test.rrajasekaran"],
            },
            {
                owner_name: "Vaishnavi - Testing",
                namespace: "vaishnavi-spark-test",
                pki_namespace: "flowsnake_test",
                users: ["vgiridaran-ltm2.internal.salesforce.com", "flowsnake_test.vgiridaran"],
                prometheus_config: std.toString(import "configs/client/vaishnavi-spark-test/prometheus-funnel-config.jsonnet"),
            },
        ],

        # ------------------------------------
        # ---------- PRD-dev fleet -----------
        # ------------------------------------
        "prd-dev-flowsnake_iot_test": [
            {
                owner_name: "Carl - Testing",
                namespace: "carl-spark-test",
                pki_namespace: "flowsnake_test",
                users: ["cmeister-ltm.internal.salesforce.com", "flowsnake_test.cmeister"],
            },
            {
                owner_name: "CRE",
                namespace: "retail-cre",
                pki_namespace: "retail-cre",
                users: [
                    "retail-cre.pmadisetti",
                    "retail-cre.lbackstrom",
                    "retail-cre.akrishna",
                    "retail-cre.blatorre",
                    "retail-cre.eantoun",
                    "retail-cre.kchaganti",
                    "retail-cre.lripple",
                    "retail-cre.macton",
                    "retail-cre.nhalko",
                    "retail-cre.pselvanandan",
                    "retail-cre.sshi",
                    "retail-cre.sthalamati",
                    "retail-cre.sruthi.vasireddy",
                    "retail-cre.tteats",
                    "retail-cre.yumrotkar",
                    "retail-cre.dvolkov",
                    "retail-cre.dkardach",
                    "retail-cre.peng.zhang",
                    "retail-cre.andrewtran",
                    "retail-cre.dangulo",
                    "retail-cre.dangulo.dangulo",
                    "retail-cre.sonia.wu",
                    "retail-cre.mariusz.tycz",
                    "retail-cre.kdaszkowski",
                    "retail-cre.dkardach",
                    "retail-cre.pkashyap",
                    "retail-cre.apandya",
                    "retail-cre.j.yang",
                    "retail-cre.j.wu",
                    "retail-cre.aadhavan.ramesh",
                    "retail-cre.ahersans",
                    "retail-cre.ebishop",
                    "retail-cre.ewulf",
                    "retail-cre.jboard",
                    "retail-cre.kdaszkowski",
                    "retail-cre.mariusz.tycz",
                    "retail-cre.cre-control-plane",
                    "retail-cre.cre-control-plane-ccp-func",
                    "retail-cre.cre-control-plane-ccp-dev",
                    "retail-cre.cre-control-plane-ccp-stage",
                    "retail-cre.cre-control-plane-cre-test",
                    "retail-cre.cre-control-plane-ccp-perf",
                    "hbase-flowsnake.xyan",
                    "hbase-flowsnake.daniel.wong",
                    "hbase-flowsnake.ckulkarni",
                    "hbase-flowsnake.jisaac",
                    "hbase-flowsnake.neha.gupta",
                    "hbase-flowsnake.nmaheshwari",
                    "hbase-flowsnake.christine.feng",
                    "hbase-flowsnake.uttam.kumar",
                ],
            },
            {
                owner_name: "Hbase",
                namespace: "hbase-flowsnake",
                pki_namespace: "hbase-flowsnake",
                users: [
                    "hbase-flowsnake.xyan",
                    "hbase-flowsnake.daniel.wong",
                    "hbase-flowsnake.ckulkarni",
                    "hbase-flowsnake.jisaac",
                    "hbase-flowsnake.neha.gupta",
                    "hbase-flowsnake.nmaheshwari",
                    "hbase-flowsnake.christine.feng",
                    "hbase-flowsnake.uttam.kumar",
                 ],
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

        # -------------------------------
        # ---------- DFW fleet ----------
        # -------------------------------
        "dfw-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- FRF fleet ----------
        # -------------------------------
        "frf-flowsnake_prod": [wave_elt_production, cre_production],

        # -------------------------------
        # ---------- HND fleet ----------
        # -------------------------------
        "hnd-flowsnake_prod": [wave_elt_production, cre_production],

        # -------------------------------
        # ---------- IA2 fleet ----------
        # -------------------------------
        "ia2-flowsnake_prod": [wave_elt_production],

        # -------------------------------
        # ---------- IAD fleet ----------
        # -------------------------------
        "iad-flowsnake_prod": [wave_elt_production, cre_production],

        # -------------------------------
        # ---------- ORD fleet ----------
        # -------------------------------
        "ord-flowsnake_prod": [wave_elt_production, cre_production],

        # -------------------------------
        # ---------- PAR fleet ----------
        # -------------------------------
        "par-flowsnake_prod": [wave_elt_production, cre_production],

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
        "ukb-flowsnake_prod": [wave_elt_production, cre_production],

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
