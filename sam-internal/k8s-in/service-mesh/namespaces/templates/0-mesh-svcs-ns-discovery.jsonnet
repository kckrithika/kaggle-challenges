## Autogenerated file.


local nsbase = import "namespaces/mesh-namespaces.jsonnet";
local configs = import "config.jsonnet";
if (nsbase.shouldDeployToKingdom("discovery", configs.kingdom)) then
        nsbase.newMeshNamespace("discovery", configs.kingdom)
else "SKIP"
