local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "Gateway",
  plural: "gateways",
  singular: "gateway",
};

local annotations = {
  "helm.sh/hook-weight": "-5",
};

istioUtils.istioCrd(crd, annotations)
