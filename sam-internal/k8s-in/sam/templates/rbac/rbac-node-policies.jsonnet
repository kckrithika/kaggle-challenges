local configs = import "config.jsonnet";
local rbac_utils = import "sam_rbac_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

# The following ClusterRole & ClusterRoleBinding allows Minion Nodes to update their own status but not others.
if samfeatureflags.rbac then {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  createRoles(node):: {
      kind: "ClusterRole",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        name: "role:" + node,
      },
      rules: [
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "nodes/status",
          ],
          resourceNames: [
            node,
          ],
          verbs: [
            "*",
          ],
        },
      ],
  },

  createClusterRoleBindings(node):: {
        kind: "ClusterRoleBinding",
        apiVersion: "rbac.authorization.k8s.io/v1alpha1",
        metadata: {
          name: "rolebinding:" + node,
        },
        subjects: [{
           kind: "User",
           name: node,
        }]
        ,
        roleRef: {
           kind: "ClusterRole",
           name: "role:" + node,
           apiGroup: "rbac.authorization.k8s.io",
        },

  },
  local minionNodes = rbac_utils.get_Nodes(configs.kingdom, configs.estate, rbac_utils.minionRole),

  local roles = std.join([], [
            [self.createRoles(node) for node in minionNodes],
        ]),
  local rolesbindings = std.join([], [
            [self.createClusterRoleBindings(node) for node in minionNodes],
        ]),

  local itemList = roles + rolesbindings,
  items: itemList,
} else "SKIP"
