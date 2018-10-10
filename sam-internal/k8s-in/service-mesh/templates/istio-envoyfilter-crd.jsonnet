local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "EnvoyFilter",
  plural: "envoyfilters",
  singular: "envoyfilter",
};

local annotations = {};

istioUtils.istioCrd(crd, annotations)
