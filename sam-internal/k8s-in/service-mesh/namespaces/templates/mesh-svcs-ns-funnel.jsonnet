## Autogenerated file.


local nsbase = import "namespaces/mesh-namespaces.jsonnet";
local configs = import "config.jsonnet";
if ((configs.estate == "prd-samdev") || (configs.estate == "prd-samtest")) then
        nsbase.newMeshNamespace("funnel")
else "SKIP"
