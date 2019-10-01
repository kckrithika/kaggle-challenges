local configs = import "config.jsonnet";
local secretsconfigs = import "secretsconfig.libsonnet";
local secretsimages = (import "secretsimages.libsonnet") + { templateFilename:: std.thisFile };

if secretsconfigs.k4aSamWdEnabled then {
    kind: "ConfigMap",
    apiVersion: "v1",
    metadata: {
        name: "k4a-sam-watchdog",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.secrets,
    },
    data: {
        "watchdog.json": std.toString(std.prune({
           caFile: configs.caFile,
           keyFile: configs.keyFile,
           certFile: configs.certFile,
           funnelEndpoint: configs.funnelVIP,
           imageName: secretsimages.k4aSamWatchdog,
           enableStatelessChecks: false,
           enableK4aChecks: true,
           smtpServer: configs.smtpServer,
        })),
    },
} else "SKIP"
