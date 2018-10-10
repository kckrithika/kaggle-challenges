local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "ServiceEntry",
  listKind: "ServiceEntryList",
  plural: "serviceentries",
  singular: "serviceentry",
};

local annotations = {};

istioUtils.istioCrd(crd, annotations)
