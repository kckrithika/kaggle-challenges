## Autogenerated file.


local nsbase = import "namespaces/mesh-namespaces.jsonnet";
local configs = import "config.jsonnet";
if (nsbase.shouldDeployToKingdom("wate-elt", configs.kingdom)) then
        nsbase.newMeshNamespace("wate-elt", configs.kingdom)
else "SKIP"
