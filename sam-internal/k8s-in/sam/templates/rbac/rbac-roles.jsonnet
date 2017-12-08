local configs = import "config.jsonnet";

if configs.kingdom == "prd" || configs.kingdom == "frf" then {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  items: [
    {
      kind: "ClusterRole",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
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
            "events",
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
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
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
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
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
     kind: "ClusterRole",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
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
} else "SKIP"
