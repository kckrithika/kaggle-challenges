// TODO: This shouldn't be necessary, fix autodeployer orphan deletion
local autodeployer = import "auto_deployer.jsonnet";
if autodeployer.samcontroldeployer["delete-orphans"] then
{
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
        name: "spark-operator-lock",
    },
}
else "SKIP"
