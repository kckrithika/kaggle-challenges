local configs = import "config.jsonnet";
local hosts = import "configs/hosts.jsonnet";
local pools = import "configs/generated-pools.jsonnet";

{
    minionRole:: "samcompute",
    masterRole:: "samkubeapi",
    allNamespaces:: "*",

    # Defines the set of estates that use the v1beta1 API version for RBAC.
    # The default is v1alpha1, which is deprecated/disabled by default in k8s 1.9.
    rbac_v1beta1_kingdoms:: std.set([
        "prd",
        "frf",
    ]),

    rbac_api_version::
        if std.setMember(configs.kingdom, $.rbac_v1beta1_kingdoms) then
             "rbac.authorization.k8s.io/v1beta1"
        else
             "rbac.authorization.k8s.io/v1alpha1",

    # Returns list of nodes in given kingdom + controlestate + role from hosts.jsonnet
    get_Nodes(kingdom, controlestate, role):: [h.hostname for h in hosts.hosts if h.kingdom == kingdom && h.controlestate == controlestate && h.devicerole == role],

    # Returns list of nodes in given kingdom + estate + role from hosts.jsonnet
    get_Estate_Nodes(kingdom, estate, role):: [h.hostname for h in hosts.hosts if h.kingdom == kingdom && h.estate == estate && h.devicerole == role],

    # Returns list of nodes in given kingdom + control estate + estate + role from hosts.jsonnet
    get_ControlEstate_Nodes(kingdom, controlestate, estate, role):: [h.hostname for h in hosts.hosts if h.kingdom == kingdom && h.controlestate == controlestate && h.estate == estate && h.devicerole == role],

    # Returns list of minion estate in given kingdom + controlestate  from hosts.jsonnet
    get_Minion_Estates(kingdom, controlestate):: std.uniq(std.sort([h.estate for h in hosts.hosts if h.kingdom == kingdom && h.controlestate == controlestate && h.devicerole == $.minionRole])),

    # Returns list of namespaces in given kingdom & estate from pools.jsonnet
           #  Adding "sam-system, sam-watchdog" namespace.
    getNamespaces(kingdom, estate):: std.uniq(std.sort(std.join([], [
            [namespace for namespace in pool.namespaces]
            for pool in pools.generatedPools
    if pool.kingdom == kingdom && pool.estate == estate
        ]))),

    # In production DC SAM control estate nodes get cluster-admin permission
    # In PRD only kubeapi nodes get cluster-admin permission
    getMasterNodes(kingdom, controlestate):: if kingdom == "prd" then $.get_Nodes(kingdom, controlestate, $.masterRole) else [h.hostname for h in hosts.hosts if h.kingdom == kingdom && h.estate == controlestate],
  }
