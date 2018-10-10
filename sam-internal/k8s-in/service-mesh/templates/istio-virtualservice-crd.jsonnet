local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "VirtualService",
  listKind: "VirtualServiceList",
  plural: "virtualservices",
  singular: "virtualservice",
};

local annotations = {};

istioUtils.istioCrd(crd, annotations)
