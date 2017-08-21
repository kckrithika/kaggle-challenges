local rbacconfigs = import "rbacconfig.jsonnet";
local configs = import "config.jsonnet";

# The following ClusterRole & ClusterRoleBinding allows Minion Nodes to update their own status but not others. 
if configs.estate == "prd-samtest" then {
  "apiVersion": "v1",
  "kind": "List",
  "metadata": {},
  estateConfig:: rbacconfigs[configs.kingdom][configs.estate],
  createRoles(node):: {
      kind: "ClusterRole",
      apiVersion: "rbac.authorization.k8s.io/v1alpha1",
      metadata: {
        "name": "update-node-status:" + node
      },
      rules: [
        {
          "apiGroups": [
            "*"
          ],
          "resources": [
            "nodes/status"
          ],
          "resourceNames": [
            node
          ],
          "verbs": [
            "*"
          ]
        }
      ]
  },

  createClusterRoleBindings(node):: {
        kind: "ClusterRoleBinding",
        apiVersion: "rbac.authorization.k8s.io/v1alpha1",
        metadata: {
          name: "update-node-status:" + node
        },
        subjects: [{
           kind: "User",
           name: node
        }]
        ,
        roleRef: {
           kind: "ClusterRole",
           name: "update-node-status:" + node,
           apiGroup: "rbac.authorization.k8s.io"
        } 

  },
  local roles = std.join([], [
            local minionNodes =  minionPool.hosts;
            [self.createRoles(node) for node in minionNodes]
            for minionPool in self.estateConfig.minion
        ]),
  local rolesbindings = std.join([], [
            local minionNodes =  minionPool.hosts;
            [self.createClusterRoleBindings(node) for node in minionNodes]
            for minionPool in self.estateConfig.minion
        ]),
        
  local itemList = roles + rolesbindings,
  "items": itemList
} else "SKIP" 
 
