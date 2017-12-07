local hosts = import "configs/hosts.jsonnet";
local pools = import "configs/generated-pools.jsonnet";

{
    minionRole:: "samcompute",
    masterRole:: "samkubeapi",

    # Returns list of nodes in given kingdom + controlestate + role from hosts.jsonnet
    get_Nodes(kingdom, controlestate, role):: [h.hostname for h in hosts.hosts if h.kingdom == kingdom && h.controlestate == controlestate && h.devicerole == role],

    # Returns list of nodes in given kingdom + estate + role from hosts.jsonnet
    get_Estate_Nodes(kingdom, estate, role):: [h.hostname for h in hosts.hosts if h.kingdom == kingdom && h.estate == estate && h.devicerole == role],

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
