local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";

if utils.is_aws(configs.kingdom) then
"SKIP"
else
{
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "samcontrol-deployer",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.sam + configs.pcnEnableLabel,
    },
    data: {
        "samcontroldeployer.json": std.toString(import "configs/samcontrol-deployer-config.jsonnet"),
    },
}
