## Autogenerated file.


local nsbase = import "namespaces/mesh-namespaces.jsonnet";
local configs = import "config.jsonnet";
if (nsbase.shouldDeployToKingdom("retail-rrps", configs.kingdom)) then
        nsbase.newMeshNamespace("retail-rrps")
else "SKIP"
