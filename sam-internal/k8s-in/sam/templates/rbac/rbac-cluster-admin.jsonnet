local rbac_utils = import "sam_rbac_functions.jsonnet";
local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

if !utils.is_public_cloud(configs.kingdom) && !utils.is_gia(configs.kingdom) then {
    kind: "ClusterRoleBinding",
    apiVersion: "rbac.authorization.k8s.io/v1alpha1",
    metadata: {
        name: "cluster-admin",
    },
    subjects: [
      {
        kind: "User",
        name: masterNode,
      }
      for masterNode in rbac_utils.getMasterNodes(configs.kingdom, configs.estate)
    ],
    roleRef: {
        kind: "ClusterRole",
        #cluster-admin role is created by k8s API server
        #Allows super-user access to perform any action on any resource. When used in a ClusterRoleBinding, it gives full control over every resource in the cluster and in all namespaces.
        name: "cluster-admin",
        apiGroup: "rbac.authorization.k8s.io",
    },
} else "SKIP"
