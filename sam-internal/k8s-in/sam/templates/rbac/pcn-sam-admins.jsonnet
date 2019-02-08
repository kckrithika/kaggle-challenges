local configs = import "config.jsonnet";
local admins = import "configs/pcn-sam-admins.json";
local rbac_utils = import "sam_rbac_functions.jsonnet";
local utils = import "util_functions.jsonnet";

if utils.is_pcn(configs.kingdom) then
{
  apiVersion: rbac_utils.rbac_api_version,
  kind: "ClusterRoleBinding",
  metadata: {
    name: "sam-admins",
    labels: {} + configs.pcnEnableLabel,
  },
  subjects: [
  {
    kind: "User",
    name: user,
    apiGroup: "rbac.authorization.k8s.io",
  }
for user in admins
],
  roleRef: {
    kind: "ClusterRole",
    name: "cluster-admin",
    apiGroup: "rbac.authorization.k8s.io",
  },
} else "SKIP"
