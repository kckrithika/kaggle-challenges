local configs = import "config.jsonnet";
local rbac_utils = import "sam_rbac_functions.jsonnet";

if configs.estate == "prd-sam" || configs.estate == "prd-sam_storage" then {
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  local storageClusters = ["prd-sam_ceph", "prd-sam_sfstore", "prd-sam_cephdev", "prd-sam_sfstoredev", "prd-sam_storage"],

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
        name: "localstorage-role:" + node,
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
          name: "localstorage-rolebinding:" + node,
        },
        subjects: [{
           kind: "User",
           name: node,
        }]
        ,
        roleRef: {
           kind: "ClusterRole",
           name: "localstorage-role:" + node,
           apiGroup: "rbac.authorization.k8s.io",
        },

   },

    local storageNodes = std.join([], [
            rbac_utils.get_ControlEstate_Nodes(configs.kingdom, configs.estate, minion, rbac_utils.minionRole)
for minion in storageClusters
]),

    local localPVRoleBindings = [self.createClusterRoleBindingForLocalPV(storageNodes)],

    local updateNodeRoles = std.join([], [
            [self.createUpdateNodeRoles(node) for node in storageNodes],
]),
    local updateNodeBindings = std.join([], [
            [self.createUpdateNodeBindings(node) for node in storageNodes],
        ]),

    local itemList = localPVRoleBindings + updateNodeRoles + updateNodeBindings,
          items: itemList,
} else "SKIP"
