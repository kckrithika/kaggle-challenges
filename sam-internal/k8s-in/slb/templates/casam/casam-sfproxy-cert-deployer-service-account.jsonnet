local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

local enabledNamespaces = [
  "slb",
  # "core-on-sam",
];

local serviceAccounts = [{
  apiVersion: "v1",
  kind: "ServiceAccount",
  metadata: {
    name: "slbpccertdeployer",
    namespace: namespace,
    labels: {
      "sam.data.sfdc.net/owner": "slb",
    },
  },
} for namespace in enabledNamespaces];

if utils.is_pcn(configs.kingdom) then {
  apiVersion: "v1",
  kind: "List",
  metadata: {
    labels: {} + configs.pcnEnableLabel,
  },
  items: serviceAccounts,
} else "SKIP"