local auto_deployer = import "auto_deployer.jsonnet";
if !auto_deployer.auto_deployer_enabled then
"SKIP"
else
{
    apiVersion: "v1",
    kind: "ConfigMap",
    metadata: {
        name: "samcontrol-deployer",
        namespace: "sam-system",
    },
    data: {
        "samcontroldeployer.json": std.toString(auto_deployer.samcontroldeployer),
    },
}
