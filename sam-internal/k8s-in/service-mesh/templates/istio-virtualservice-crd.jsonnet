local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "VirtualService",
  listKind: "VirtualServiceList",
  plural: "virtualservices",
  singular: "virtualservice",
};

local annotations = {};

if configs.estate == "prd-samtest" then
  istioUtils.istioCrd(crd, annotations)
else "SKIP"
