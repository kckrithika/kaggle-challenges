local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_images = import "flowsnake_images.jsonnet";
local configs = import "config.jsonnet";
local util = import "util_functions.jsonnet";
local flowsnake_all_kes = (import "flowsnakeEstates.json").kingdomEstates + ["prd/prd-minikube-big-flowsnake", "prd/prd-minikube-small-flowsnake"];
{
    is_minikube: std.startsWith(estate, "prd-minikube"),
    is_minikube_small: std.startsWith(estate, "prd-minikube-small"),
    fleet_name_overrides: self.validate_estate_fields({
        "prd-data-flowsnake": "sfdc-prd",
        "prd-dev-flowsnake_iot_test": "sfdc-prd-iot-poc",
    }),
    fleet_vips: self.validate_estate_fields({
        // These PRD VIPs are missing from vips.yaml but can be found in
        // https://git.soma.salesforce.com/estates/estates/blob/master/kingdoms/prd/vip-cnames.json
        // prd-data-flowsnake has a pretty/preferred CNAME that predates estate-based VIP configuration.
        "prd-data-flowsnake": "flowsnake-prd.data.sfdc.net",
        "prd-dev-flowsnake_iot_test": "dev0shared0-flowsnakeiottest1-0-prd.data.sfdc.net",
        "prd-data-flowsnake_test": "flowsnake-test1-0-prd.data.sfdc.net",
        // Production VIPs (flowsnake_worker_prod estate roles) are defined in estates:
        // https://git.soma.salesforce.com/estates/estates/blob/master/conf/vips.yaml
        "iad-flowsnake_prod": "flowsnake-iad.data.sfdc.net",
        "ord-flowsnake_prod": "flowsnake-ord.data.sfdc.net",
        "phx-flowsnake_prod": "flowsnake-phx.data.sfdc.net",
        "frf-flowsnake_prod": "flowsnake-frf.data.sfdc.net",
        "par-flowsnake_prod": "flowsnake-par.data.sfdc.net",
        "dfw-flowsnake_prod": "flowsnake-dfw.data.sfdc.net",
        "ia2-flowsnake_prod": "flowsnake-ia2.data.sfdc.net",
        "ph2-flowsnake_prod": "flowsnake-ph2.data.sfdc.net",
        "hnd-flowsnake_prod": "flowsnake-hnd.data.sfdc.net",
        "ukb-flowsnake_prod": "flowsnake-ukb.data.sfdc.net",
        // MoFo estates do not have Flowsnake v1; no ingress-controller, no VIP in front of it.
        // However, they have Event Exporter, and the current implementation of that requires Fleet Config,
        // and that requires a VIP. So, for now, we keep these bogus entries.
        "yul-flowsnake_prod": "flowsnake-yul.data.sfdc.net",
        "yhu-flowsnake_prod": "flowsnake-yhu.data.sfdc.net",
        "syd-flowsnake_prod": "flowsnake-syd.data.sfdc.net",
        "cdu-flowsnake_prod": "flowsnake-cdu.data.sfdc.net",
        // minikube fake VIPs
        "prd-minikube-small-flowsnake": "prd-minikube-small-flowsnake.data.sfdc.net",
        "prd-minikube-big-flowsnake": "prd-minikube-big-flowsnake.data.sfdc.net",
    }),
    # Map to the "pod" or "cluster" names used in iDB and Splunk
    idb_cluster_name_overrides: self.validate_estate_fields({
        "prd-data-flowsnake": "flowsnake",
        "prd-dev-flowsnake_iot_test": "flowsnake_iot_poc",
        "prd-data-flowsnake_test": "flowsnake_test",
    }),

    is_public_cloud: util.is_public_cloud(configs.kingdom),
    sdn_enabled: !self.is_minikube && !self.is_public_cloud,
    # no v1 in PCL
    is_v1_enabled: !self.is_public_cloud && kingdom != "ph2" && kingdom != "ia2",

    # Whether the autodeployer should delete orphans.  This is an unreliable feature
    # and so is mostly disabled.  Additionally it CANNOT be enabled anywhere v1 is running
    # because v1 creates resources in the flowsnake namespace dynamically.

    autodeployer_deletes_orphans: !self.is_v1_enabled && self.is_public_cloud,

    # Standard SLB vip name is: <lbname>-<team-<kingdom>.slb.sfdc.net
    # Presume lbname is derived from role munged the same way as for ServiceMesh.
    # (Some munging required to distinguish between multiple instances in a single kingdom)
    # MoFo estates have differnt naming pattern. (Because technically no SLB, must use F5s).
    slb_fqdn(role):: $.role_munge_for_estate(role) + "-flowsnake-" + kingdom +
        (if (self.is_public_cloud) then ".data.sfdc.net" else ".slb.sfdc.net"),

    # api_public_name is combined with other coordinates (team, datacenter) to produce
    # publicly visible endpoints. Intentionaly not named impersonation-proxy, because that's an implementation detail
    # our customers don't care about.
    api_public_name: "kubernetes-api",
    # SLB SAN matches lbname in sam-manifests/apps/team/flowsnake/vips/prd/vips.yaml
    api_slb_fqdn: self.slb_fqdn(self.api_public_name),

    # The suffix applied to the PKI role for each estate. PKI role is yet another "role" concept at Salesforce. It is
    # more commonly referred to as the application name (based on its use in SAM). It is what is in the OU 0 field of
    # MadDog certficate.
    role_estate_suffixes:: self.validate_estate_fields({
        "prd-dev-flowsnake_iot_test": "-dev",
        "prd-data-flowsnake_test": "-test",
        "prd-minikube-small-flowsnake": "-minikube",
        "prd-minikube-big-flowsnake": "-minikube",
    }),

    # The ServiceMesh-visible hostname of components varies between test and production fleets.
    # E.g. api-dev.flowsnake.localhost.mesh.force.com for the Ingress Controller hosted in prd-dev vs.
    # api.flowsnake.localhost.mesh.force.com for one hosted in production.
    # (The Kingdom is not included; so e.g. whether api.flowsnake.localhost.mesh.force.com resolves to prd-data, IAD,
    # ORD, etc. depends on where you're calling from!)
    role_munge_for_estate(role):: role +
        if std.objectHas($.role_estate_suffixes, estate) then $.role_estate_suffixes[estate]
        else "",

    service_mesh_fqdn(role):: $.role_munge_for_estate(role) + ".flowsnake.localhost.mesh.force.com",

    # Maps an estate to the estate-role (see https://git.soma.salesforce.com/estates/estates/blob/master/conf/roles.yaml)
    # of the master nodes in that fleet. Estate role is not to be confused with deviceRole (aka GUS role aka Puppet role).
    # We care about the estate roles because they flow into the MadDog host certs' SAN as <estate-role>.sfdc-role.
    # This is our current work-around (along with host aliases) to open TLS connections to KubeAPI until we can get the
    # kubernetes.default.svc.cluster.local name added directly to the cert.
    #
    # The actual role names use underscores, but the PKI cert names use hyphens. std.strReplace is only available in
    # jsonnet 0.10.0 and up, so just put the munged values in here.
    estate_master_role_per_estate:: self.validate_estate_fields({
        "prd-data-flowsnake": "flowsnake-master",
        "prd-dev-flowsnake_iot_test": "flowsnake-master-iot-test",
        "prd-data-flowsnake_test": "flowsnake-master-test",
        # minikube values are just invented; need to reconcile with reality once MadKub working in minikube
        "prd-minikube-small-flowsnake": "flowsnake-master-minikube",
        "prd-minikube-big-flowsnake": "flowsnake-master-minikube",
    }),  # default: flowsnake_master_prod

    # The estate role names use underscores, but the value here contain hyphens to match what is found in the MadDog
    # cert SANs.
    # std.strReplace is only available in Jsonnet v0.10.0 and higher. https://github.com/google/jsonnet/releases/tag/v0.10.0
    estate_master_role::
        local hyphenize(s) = std.join("", std.map(function(c) if c == '_' then '-' else c, std.stringChars(s)));
        hyphenize(
            (if std.objectHas(self.estate_master_role_per_estate, estate) then
                self.estate_master_role_per_estate[estate]
            else "flowsnake_master_prod")
            + ".sfdc-role"
        ),

    default_image_pull_policy: if self.is_minikube then "Never" else "IfNotPresent",
    deepsea_enabled_estates: [
        "prd-data-flowsnake",
        "prd-data-flowsnake_test",
    ],
    deepsea_enabled: std.count(self.deepsea_enabled_estates, estate) > 0,
    // Note: true if pki_agent working. Includes both "enabled" and "in-transition" Puppet settings
    // False for Minikube, which supports MadKub for tenant certs but does not have PKI agent running on the
    // node itself.
    host_pki_agent_enabled: !self.is_minikube,
    // Prefer cert_services certs on these estates. (But use MadDog cabundle if maddog_enabled)
    cert_services_preferred_estates: [
        "prd-data-flowsnake",
        "prd-dev-flowsnake_iot_test",
    ],
    cert_services_preferred: std.count(self.cert_services_preferred_estates, estate) == 1,
    fleet_name: if self.is_minikube then
            # See flowsnake-platform/flowsnake-config
            "minikube"
        else if std.objectHas(self.fleet_name_overrides, estate) then
            $.fleet_name_overrides[estate]
        else
            estate,
    idb_cluster_name: if self.is_minikube then
            "minikube"
        else if std.objectHas(self.idb_cluster_name_overrides, estate) then
            $.idb_cluster_name_overrides[estate]
        else
            estate,
    is_test: (
        estate == "prd-data-flowsnake_test"
    ),
    is_phase2_fleet: (
        estate == "prd-data-flowsnake" || estate == "prd-dev-flowsnake_iot_test" || kingdom == "frf" || kingdom == "cdu"
    ),
    is_r_and_d: (
        kingdom == "prd"
    ),
    snapshots_enabled: !self.is_minikube,
    registry: if self.is_minikube then "minikube" else configs.registry,
    strata_registry: if self.is_minikube then "minikube" else configs.registry + "/dva",
    funnel_vip: "ajna0-funnel1-0-" + kingdom + ".data.sfdc.net",
    funnel_vip_and_port: $.funnel_vip + ":80",
    funnel_endpoint: "http://" + $.funnel_vip_and_port,
    madkub_endpoint: if self.is_minikube then "https://madkubserver:32007" else "https://10.254.208.254:32007",  // TODO: Fix kubedns so we do not need the IP
    maddog_endpoint: if self.is_minikube then "https://maddog-onebox:8443" else configs.maddogEndpoint,
    madkub_enabled: !self.is_minikube,
    service_mesh_enabled: !self.is_minikube,
    kubedns_manifests_enabled: !self.is_minikube,
    # Performance impact of logging DNS queries unknown. In test fleet alone it is ~5000 per minute. Presume this can
    # only be done temporarily.
    kubedns_cache_size: 50000,
    kubedns_synthetic_requests_estates: {
        "prd-data-flowsnake_test": {
            replicas: 5,
            rate: 100,  # requests per second per replica
        },
        "prd-dev-flowsnake_iot_test": {
            replicas: 20,
            rate: 50,  # requests per second per replica
        },
        "iad-flowsnake_prod": {
            replicas: 20,
            rate: 50,  # requests per second per replica
        },
    },
    # Query logging theoretically independent of synthetic requests, for now we enable them together.
    kubedns_log_queries: std.objectHas(self.kubedns_synthetic_requests_estates, estate),
    kubedns_synthetic_requests: std.objectHas(self.kubedns_synthetic_requests_estates, estate),
    kubedns_synthetic_requests_config: if std.objectHas(self.kubedns_synthetic_requests_estates, estate) then
        self.kubedns_synthetic_requests_estates[estate] else {},
    node_controller_enabled: !self.is_minikube,

    # State of RBAC in kubernetes
    #   disabled          no RBAC anything.
    #   host_only         host certs have cluster-admin rights
    #   host_and_user     host certs have cluster-admin rights; Flowsnake (cluster)roles are created and bound to service accounts and client user IDs
    #   user_only         Flowsnake (cluster)roles are created and bound to service accounts and client user IDs
    # It is expected that legacy clusters will start at the top of this list and proceed downward one step at a time; host_only is necessary
    # before changing the api server to use RBAC to bootstrap existing clusters. New clusters will be bootstrapped by starting the api server
    # with AllowAny

    kubernetes_rbac_stage: if self.is_minikube then
            "user_only"
        else
            "host_and_user",

    kubernetes_hosts_are_admin: self.kubernetes_rbac_stage == "host_only" || self.kubernetes_rbac_stage == "host_and_user",
    kubernetes_create_user_auth: self.kubernetes_rbac_stage == "host_and_user" || self.kubernetes_rbac_stage == "user_only",

    impersonation_proxy_enabled: self.madkub_enabled,
    impersonation_proxy_replicas: if self.is_test then 1 else 2,

    # Whether this is the fleet used for CI testing in Strata builds
    ci_resources_enabled: (
        estate == "prd-dev-flowsnake_iot_test" && self.kubernetes_create_user_auth
    ),

    s3_public_proxy_host: ("public0-proxy1-0-" + kingdom + ".data.sfdc.net"),

    ## Some utility functions for internal consistency checking

    validate_estate_fields(emap):: (
        local all_estates = [std.splitLimit(ke, "/", 1)[1] for ke in flowsnake_all_kes];
        local bad_keys = [e for e in std.objectFields(emap) if std.count(all_estates, e) == 0];
        if std.length(bad_keys) == 0
            then emap
            else error "Unknown fields in estate map: " + std.join(" ", bad_keys)
    ),

    validate_kingdom_estate_fields(kemap):: (
        local bad_keys = [ke for ke in std.objectFields(kemap) if std.count(flowsnake_all_kes, ke) == 0];
        if std.length(bad_keys) == 0
        then kemap
        else error "Unknown fields in kingdom/estate map: " + std.join(" ", bad_keys)
    ),

    # estate that has hbase connections & have watchdog runnign on
    hbase_enabled_estates: [
        "prd-dev-flowsnake_iot_test",
        "iad-flowsnake_prod",
        "ord-flowsnake_prod",
        "frf-flowsnake_prod",
        "par-flowsnake_prod",
        "hnd-flowsnake_prod",
        "ukb-flowsnake_prod",
    ],
    hbase_dev_estates: [
        "prd-dev-flowsnake_iot_test",
    ],
    hbase_prod_estates: [
        "iad-flowsnake_prod",
        "ord-flowsnake_prod",
        "frf-flowsnake_prod",
        "par-flowsnake_prod",
        "hnd-flowsnake_prod",
        "ukb-flowsnake_prod",
    ],
    hbase_enabled: std.count(self.hbase_enabled_estates, estate) > 0,
    hbase_dev_watchdog_enabled: std.count(self.hbase_dev_estates, estate) > 0,
    hbase_prod_watchdog_enabled: std.count(self.hbase_prod_estates, estate) > 0,

    sherpa_resources: (
if estate != "prd-flowsnake_iot_test" then false else
        {
            requests: {
                cpu: "2.0",
                memory: "4Gi",
            },
            limits: {
                cpu: "2.0",
                memory: "4Gi",
            },
        }
    ),
}
