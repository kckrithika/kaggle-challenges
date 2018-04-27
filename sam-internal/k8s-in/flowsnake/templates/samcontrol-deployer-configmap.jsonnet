local auto_deployer = import "auto_deployer.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
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
