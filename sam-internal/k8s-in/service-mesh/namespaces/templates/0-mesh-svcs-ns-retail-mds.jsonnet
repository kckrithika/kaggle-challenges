## Autogenerated file.


local nsbase = import "namespaces/mesh-namespaces.jsonnet";
local configs = import "config.jsonnet";
if (nsbase.shouldDeployToKingdom("retail-mds", configs.kingdom)) then
        nsbase.newMeshNamespace("retail-mds")
else "SKIP"
