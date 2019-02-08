local configs = import "config.jsonnet";
local debugusers = import "configs/pcn-debug-user-list.json";
local rbac_utils = import "sam_rbac_functions.jsonnet";

local functions = {
    createDebugRole(namespace):: {
        kind: "Role",
        apiVersion: rbac_utils.rbac_api_version,
        metadata: {
          name: "debug",
          namespace: namespace,
        },
        rules: [
            {
                apiGroups: [""],
                resources: ["pods", "pods/portforward"],
                verbs: ["get", "list", "create"],
            },
            {
              apiGroups: [""],
              resources: ["pods/log"],
              verbs: ["get", "list"],
            },
            {
              apiGroups: [""],
              resources: ["pods/exec"],
              verbs: ["create"],
            },
        ],
    },
    createUserRoleBinding(namespace, users):: {
      kind: "RoleBinding",
      apiVersion: rbac_utils.rbac_api_version,
      metadata: {
        name: "debug",
        namespace: namespace,
      },
      subjects: [
        {
          kind: "User",
          name: user,
          apiGroup: "rbac.authorization.k8s.io",
        }
for user in users
      ],
      roleRef: {
        kind: "Role",
        name: "debug",
        apiGroup: "rbac.authorization.k8s.io",
      },
  },
};

if (configs.estate == "gsf-core-devmvp-sam2-sam") then
{
  apiVersion: "v1",
  kind: "List",
  metadata: {
    labels: {} + configs.pcnEnableLabel,
  },
  items: (
    [functions.createDebugRole(entry.namespace) for entry in debugusers] +
    [functions.createUserRoleBinding(entry.namespace, entry.users) for entry in debugusers]
  ),
} else "SKIP"
