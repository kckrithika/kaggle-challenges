local auto_deployer = import "auto_deployer.jsonnet";
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";

if !auto_deployer.auto_deployer_enabled || utils.is_aws(configs.kingdom) then
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
