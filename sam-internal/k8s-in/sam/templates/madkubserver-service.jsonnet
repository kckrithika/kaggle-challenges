local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local utils = import "util_functions.jsonnet";
local samfeatureflags = import "sam-feature-flags.jsonnet";

if samfeatureflags.maddogforsamapps then {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        labels: {
            service: "madkubserver",
        } + configs.ownerLabel.sam
        + configs.pcnEnableLabel,
        name: "madkubserver",
        namespace: "sam-system",
    },
    spec: {
        ports: [
            {
                name: "madkubapitls",
                port: 32007,
                targetPort: 32007,
            },
        ],
        selector: {
            service: "madkubserver",
        },
    }
    # Hardcoding the ClusterIp for now as we dont have DNS/SLB
    + (if utils.is_pcn(configs.kingdom) then {} else { clusterIP: "10.254.208.254" }),
    status: {
        loadBalancer: {},
    },
} else "SKIP"
