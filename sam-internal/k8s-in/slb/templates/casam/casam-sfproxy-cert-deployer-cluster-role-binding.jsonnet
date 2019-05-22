local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

local enabledNamespaces = [
  "slb",
  # "core-on-sam",
];

local clusterRoleBindings = [{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRoleBinding",
  metadata: {
    name: "slb-pc-cert-deployer",
    namespace: namespace,
    labels: {
      "sam.data.sfdc.net/owner": "slb",
    },
  },
  subjects: [
    {
      kind: "ServiceAccount",
      name: "slbpccertdeployer",
      namespace: namespace,
    },
  ],
  roleRef: {
    kind: "ClusterRole",
    name: "slb-pc-cert-deployer",
    apiGroup: "rbac.authorization.k8s.io",
  },
} for namespace in enabledNamespaces];

if utils.is_pcn(configs.kingdom) && !utils.is_aws(configs.kingdom) then {
  apiVersion: "v1",
  kind: "List",
  metadata: {
    labels: {} + configs.pcnEnableLabel,
  },
  items: clusterRoleBindings,
} else "SKIP"