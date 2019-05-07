local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

local enabledNamespaces = [
  "slb",
  # "core-on-sam",
];

local clusterRoles = [{
  apiVersion: "rbac.authorization.k8s.io/v1beta1",
  kind: "ClusterRole",
  metadata: {
    name: "slb-pc-cert-deployer",
    namespace: namespace,
    labels: {
      "sam.data.sfdc.net/owner": "slb",
    },
  },
  rules: [
    {
      apiGroups: ["*"],
      resources: ["services"],
      verbs: ["list", "get", "watch"],
      },
  ],
} for namespace in enabledNamespaces];

if utils.is_pcn(configs.kingdom) then {
  apiVersion: "v1",
  kind: "List",
  metadata: {
    labels: {} + configs.pcnEnableLabel,
  },
  items: clusterRoles,
} else "SKIP"
