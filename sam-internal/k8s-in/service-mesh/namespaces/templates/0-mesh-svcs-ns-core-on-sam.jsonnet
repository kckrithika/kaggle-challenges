## Autogenerated file.


local nsbase = import "namespaces/mesh-namespaces.jsonnet";
local configs = import "config.jsonnet";
if (nsbase.shouldDeployToKingdom("core-on-sam", configs.kingdom)) then
        nsbase.newMeshNamespace("core-on-sam")
else "SKIP"
