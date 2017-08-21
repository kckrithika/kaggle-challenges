local rbacconfigs = import "rbacconfig.jsonnet";
local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
  "apiVersion": "v1",
  "kind": "List",
  "metadata": {},
  local estateConfig = rbacconfigs[configs.kingdom][configs.estate],
  createRoleBinding(namespace, hosts):: {
      #Gives permission to read secrets & update events & pod status in the rolebinding's namespace
      "kind": "RoleBinding",
      "apiVersion": "rbac.authorization.k8s.io/v1alpha1",
      "metadata": {
        #All the $namespaces deployed on the $pool the node is part of should have rolebinding to "minion:role"
        "name": namespace + ":rolebinding",
        "namespace": namespace
      },
      "subjects": [
        {
          "kind": "User",
          "name": minionnode
        } for minionnode in hosts
      ],
      "roleRef": {
        "kind": "ClusterRole",
        "name": "minion:role",
        "apiGroup": "rbac.authorization.k8s.io"
      }
  },
  createClusterRoleBinding(hosts):: {
      #Gives permission to read secrets & update events &pod status in the cluster and in all namespaces.
      "kind": "ClusterRoleBinding",
      "apiVersion": "rbac.authorization.k8s.io/v1alpha1",
      "metadata": {
        # In PRD samcompute nodes get permission to read secrets, update pod/status & events across all namespace
        "name": "samcompute:clusterrolebinding",
      },
      "subjects": [
        {
          "kind": "User",
          "name": minionnode
        } for minionnode in hosts
      ],
      "roleRef": {
        "kind": "ClusterRole",
        "name": "minion:role",
        "apiGroup": "rbac.authorization.k8s.io"
      }
  },
  local roleBindings = std.join([], [
            local hosts =  pool.hosts;
            local namespaces = pool.namespaces;
            local poolName = pool.pool;
            # In Prod samcompute & samkubeapi nodes get admin access.
            # In PRD customer apps run on samcompute nodes. So samcompute nodes get restricted access but all the permissions are across namespace(clusterRoleBinding)
            [if configs.kingdom == "prd" && poolName == "samcompute" then self.createClusterRoleBinding(hosts) else self.createRoleBinding(namespace, hosts) for namespace in namespaces]
            for pool in estateConfig.minion
        ]),

  local clusterRoleBindings = [
     {
      "kind": "ClusterRoleBinding",
      "apiVersion": "rbac.authorization.k8s.io/v1alpha1",
      "metadata": {
        "name": "cluster-admin"
      },
      "subjects": [
        {
          "kind": "User",
          "name": masterNode
        } for masterNode in estateConfig.master
      ],
      "roleRef": {
        "kind": "ClusterRole",
        #cluster-admin role is created by k8s API server 
        #Allows super-user access to perform any action on any resource. When used in a ClusterRoleBinding, it gives full control over every resource in the cluster and in all namespaces.
        "name": "cluster-admin",
        "apiGroup": "rbac.authorization.k8s.io"
      }
    },
    {
      #Gives permission to read "services", "pods", "nodes" & "endpoints", create "nodes" in the cluster and across all namespaces.
      "kind": "ClusterRoleBinding",
      "apiVersion": "rbac.authorization.k8s.io/v1alpha1",
      "metadata": {
        "name": "minion:clusterrolebinding"
      },
      "subjects": [
        {
          "kind": "Group",
          # system:authenticated has list of all authenticated users
          "name": "system:authenticated"
        } 
      ],
      "roleRef": {
        "kind": "ClusterRole",
        "name": "minion:clusterrole",
        "apiGroup": "rbac.authorization.k8s.io"
     
      }
    },
    {
      #Gives permission to read-write "secrets" in sam-system namespaces.
      "kind": "RoleBinding",
      "apiVersion": "rbac.authorization.k8s.io/v1alpha1",
      "metadata": {
        "name": "update-secrets",
        "namespace": "sam-system"
      },
      "subjects": [
        {
          "kind": "Group",
          # system:authenticated has list of all authenticated users
          "name": "system:authenticated"
        } 
      ],
      "roleRef": {
        "kind": "Role",
        "name": "update-secrets",
        "apiGroup": "rbac.authorization.k8s.io"
     
      }
    }

  ],

  "items": clusterRoleBindings + roleBindings
} else "SKIP" 
