## Autogenerated file.


local nsbase = import "namespaces/mesh-namespaces.jsonnet";
local configs = import "config.jsonnet";
if (nsbase.shouldDeployToKingdom("retail-cre", configs.kingdom)) then
        nsbase.newMeshNamespace("retail-cre", configs.kingdom)
else "SKIP"
