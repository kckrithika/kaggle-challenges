local configs = import "config.jsonnet";
local rbac_utils = import "sam_rbac_functions.jsonnet";

if configs.estate == "prd-sam" then {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  local cephClusters = ["prd-sam_ceph", "prd-sam_sfstore"],

  createClusterRoleBindingForLocalPV(hosts):: {
      kind: "ClusterRoleBinding",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        name: "local-pv-create",
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
        name: "local-pv-create",
        apiGroup: "rbac.authorization.k8s.io",
      },
  },

  createUpdateNodeRoles(node):: {
      kind: "ClusterRole",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        name: "ceph-role:" + node,
      },
      rules: [
        {
          apiGroups: [
            "*",
          ],
          resources: [
            "nodes",
          ],
          resourceNames: [
            node,
          ],
          verbs: [
            "patch",
          ],
        },
      ],
   },

   createUpdateNodeBindings(node):: {
        kind: "ClusterRoleBinding",
        apiVersion: "rbac.authorization.k8s.io/v1alpha1",
        metadata: {
          name: "ceph-rolebinding:" + node,
        },
        subjects: [{
           kind: "User",
           name: node,
        }]
        ,
        roleRef: {
           kind: "ClusterRole",
           name: "ceph-role:" + node,
           apiGroup: "rbac.authorization.k8s.io",
        },

   },

    local cephNodes = std.join([], [
            rbac_utils.get_Estate_Nodes(configs.kingdom, minion, rbac_utils.minionRole)
for minion in cephClusters
]),

    local localPVRoleBindings = [self.createClusterRoleBindingForLocalPV(cephNodes)],

    local updateNodeRoles = std.join([], [
            [self.createUpdateNodeRoles(node) for node in cephNodes],
]),
    local updateNodeBindings = std.join([], [
            [self.createUpdateNodeBindings(node) for node in cephNodes],
        ]),

    local itemList = localPVRoleBindings + updateNodeRoles + updateNodeBindings,
          items: itemList,
} else "SKIP"
