local configs = import "config.jsonnet";
local rbac_utils = import "sam_rbac_functions.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  createRoleBinding(namespace, estate, hosts):: {
      #Gives permission to read secrets & update events & pod status in the rolebinding's namespace
      kind: "RoleBinding",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        #All the $namespaces deployed on the $pool the node is part of should have rolebinding to "minion:role"
        name: namespace + ":" + estate + ":rolebinding",
        namespace: namespace,
      },
      subjects: [
        {
          kind: "User",
          name: minionnode,
        }
for minionnode in hosts
      ],
      roleRef: {
        kind: "ClusterRole",
        name: "minion:role",
        apiGroup: "rbac.authorization.k8s.io",
      },
  },
  createClusterRoleBinding(hosts):: {
      #Gives permission to read secrets & update events &pod status in the cluster and in all namespaces.
      kind: "ClusterRoleBinding",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        # In PRD samcompute nodes get permission to read secrets, update pod/status & events across all namespace
        name: "samcompute:clusterrolebinding",
      },
      subjects: [
        {
          kind: "User",
          name: minionnode,
        }
for minionnode in hosts
      ],
      roleRef: {
        kind: "ClusterRole",
        name: "minion:role",
        apiGroup: "rbac.authorization.k8s.io",
      },
  },

  local roleBindings = std.join([], [
            local hosts = rbac_utils.get_Estate_Nodes(configs.kingdom, minionEstate, rbac_utils.minionRole);
            # In Prod samcompute & samkubeapi nodes get admin access.
            # In PRD customer apps run on samcompute nodes. So samcompute nodes get restricted access but all the  permissions are across namespace(clusterRoleBinding)
            if configs.kingdom == "prd" && utils.is_test_cluster(minionEstate) then [self.createClusterRoleBinding(hosts)] else [self.createRoleBinding(namespace, minionEstate, hosts) for namespace in rbac_utils.getNamespaces(configs.kingdom, minionEstate)]
            for minionEstate in rbac_utils.get_Minion_Estates(configs.kingdom, configs.estate)
        ]),

  local clusterRoleBindings = [
    {
      #Gives permission to read "services", "pods", "nodes" & "endpoints", create "nodes" in the cluster and across all namespaces.
      kind: "ClusterRoleBinding",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        name: "minion:clusterrolebinding",
      },
      subjects: [
        {
          kind: "Group",
          # system:authenticated has list of all authenticated users
          name: "system:authenticated",
        },
      ],
      roleRef: {
        kind: "ClusterRole",
        name: "minion:clusterrole",
        apiGroup: "rbac.authorization.k8s.io",

      },
    },
    {
     #Gives permission to read secrets & update events & pod status in the sam-system namespace
      kind: "RoleBinding",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        name: "sam-system:rolebinding",
        namespace: "sam-system",
      },
      subjects: [
        {
          kind: "Group",
          # system:authenticated has list of all authenticated users
          name: "system:authenticated",
        },
      ],
      roleRef: {
        kind: "ClusterRole",
        name: "minion:role",
        apiGroup: "rbac.authorization.k8s.io",
      },
    },
    {
     #Gives permission to read secrets & update events & pod status in the sam-watchdog namespace
      kind: "RoleBinding",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        name: "sam-watchdog:rolebinding",
        namespace: "sam-watchdog",
      },
      subjects: [
        {
          kind: "Group",
          # system:authenticated has list of all authenticated users
          name: "system:authenticated",
        },
      ],
      roleRef: {
        kind: "ClusterRole",
        name: "minion:role",
        apiGroup: "rbac.authorization.k8s.io",
      },
    },
    {
      #Gives permission to read-write "secrets" in sam-system namespaces.
      kind: "RoleBinding",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        name: "update-secrets",
        namespace: "sam-system",
      },
      subjects: [
        {
          kind: "Group",
          # system:authenticated has list of all authenticated users
          name: "system:authenticated",
        },
      ],
      roleRef: {
        kind: "Role",
        name: "update-secrets",
        apiGroup: "rbac.authorization.k8s.io",
    },
    },

  ],

  items: clusterRoleBindings + roleBindings,
} else "SKIP"
