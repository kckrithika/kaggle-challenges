local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "EnvoyFilter",
  plural: "envoyfilters",
  singular: "envoyfilter",
};

local annotations = {};

if configs.estate == "prd-samtest" then
  istioUtils.istioCrd(crd, annotations)
else "SKIP"
