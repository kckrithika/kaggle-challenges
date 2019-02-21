local configs = import "config.jsonnet";
local rbac_utils = import "sam_rbac_functions.jsonnet";

{
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  items: [
    {
      kind: "ClusterRole",
      apiVersion: rbac_utils.rbac_api_version,
      metadata: {
        #When used in a ClusterRoleBinding, it gives permission to read secrets & update events &pod status in the cluster and in all namespaces. When used in a RoleBinding, it gives permission to read secrets & update events & pod status in the rolebinding's namespace.
        # Refer to "samcompute:clusterrolebinding" & "$namespace:rolebinding"
        name: "minion:role",
      },
      rules: [
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "pods/status",
          ],
          verbs: [
            "*",
          ],
        },
        {
          apiGroups: [
             "*",
          ],
          resources: [
            "pods/exec",
             ],
             verbs: [
               "create",
             ],
        },
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "pods",
          ],
          verbs: [
            "delete",
          ],
        },
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "secrets",
            "configmaps",
            "persistentvolumeclaims",
            "pods/log",
            "deployments",
            "replicasets",
          ],
          verbs: [
            "get",
            "watch",
            "list",
          ],
        },
      ],
    },
    {
      kind: "ClusterRole",
      apiVersion: rbac_utils.rbac_api_version,
      metadata: {
        # When used in a ClusterRoleBinding, gives permission to read "services", "pods", "nodes" & "endpoints", create "nodes" in the cluster and across all namespaces. Used in "minion:clusterrolebinding".
        name: "minion:clusterrole",
      },
      rules: [
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "services",
            "endpoints",
            "nodes",
            "pods",
            "persistentvolumes",
            "statefulsets",
            "namespaces",
          ],
          verbs: [
            "get",
            "list",
            "watch",
          ],
        },
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "nodes",
          ],
          verbs: [
            # Required for node registration
            "create",
          ],
        },
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "events",
          ],
          verbs: [
            "*",
          ],
        },
        {
          nonResourceURLs: [
            "*",
          ],
          verbs: [
            "*",
          ],
        },
      ],
    },
    {
     kind: "Role",
      apiVersion: rbac_utils.rbac_api_version,
      metadata: {
         name: "update-secrets",
         namespace: "sam-system",
      },
      rules: [
        {
          apiGroups: [
             "*",
          ],
          resources: [
             "secrets",
          ],
          verbs: [
             "*",
          ],
       },
      ],
    },
    {
     kind: "Role",
      apiVersion: rbac_utils.rbac_api_version,
      metadata: {
         name: "update-crd",
         namespace: "sam-system",
      },
      rules: [
        {
          apiGroups: [
             "samcrd.salesforce.com",
          ],
          resources: [
             "watchdogs",
          ],
          verbs: [
             "*",
          ],
       },
      ],
    },
    {
     kind: "ClusterRole",
      apiVersion: rbac_utils.rbac_api_version,
      metadata: {
         name: "local-pv-create",
      },
      rules: [
        {
          apiGroups: [
             "*",
          ],
          resources: [
             "persistentvolumes",
          ],
          verbs: [
             "*",
          ],
       },
      ],
    },

  ],
}
