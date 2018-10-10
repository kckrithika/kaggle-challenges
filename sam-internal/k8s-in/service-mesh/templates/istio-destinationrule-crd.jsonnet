local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "DestinationRule",
  listKind: "DestinationRuleList",
  plural: "destinationrules",
  singular: "destinationrule",
};

local annotations = {};

istioUtils.istioCrd(crd, annotations)
