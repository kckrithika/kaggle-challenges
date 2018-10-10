local configs = import "config.jsonnet";
local istioUtils = import "istio-utils.jsonnet";

local crd = {
  kind: "ServiceEntry",
  listKind: "ServiceEntryList",
  plural: "serviceentries",
  singular: "serviceentry",
};

local annotations = {};

if configs.estate == "prd-samtest" then
  istioUtils.istioCrd(crd, annotations)
else "SKIP"
