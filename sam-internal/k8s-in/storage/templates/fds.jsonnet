local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storagedev",
    "prd-sam_storage",
    "prd-sam",
    "prd-skipper",
]);

// Init containers for the pod.
local initContainers = [
    storageimages.log_init_container(
        storageimages.loginit,
        "fds",
        7337,
        7337,
        "sfdc"
    ),
];

// Volume Mounts for the FDS container.
local fdsVolumeMounts =
    storageutils.log_init_volume_mounts() +
    storageutils.cert_volume_mounts();

// Environment variables for the FDS container.
local fdsEnvironmentVars = std.prune([
    if configs.estate != "prd-skipper" then configs.kube_config_env else null,
    {
        name: "FDS_PROFILING",
        value: storageconfigs.fds_profiling,
    },
]);

// Volumes available to the pod.
local podVolumes =
    storageutils.log_init_volumes() +
    storageutils.cert_volume();

if std.setMember(configs.estate, enabledEstates) then configs.deploymentBase("storage") {
    metadata: {
        labels: {
            name: "fds-controller",
            team: "storage-foundation",
            cloud: "storage",
        } + configs.ownerLabel.storage,
        name: "fds-controller-deployment",
        namespace: "sam-system",
    },
    spec+: {
        replicas: 1,
        strategy: {
            type: "RollingUpdate",
            rollingUpdate: {
                maxUnavailable: 1,
                maxSurge: 0,
            },
        },
        minReadySeconds: 30,
        template: {
            metadata: {
                labels: {
                    name: "fds-controller",
                    team: "storage-foundation",
                    cloud: "storage",
                },
            },
            spec: {
                initContainers: initContainers,
                containers: std.prune([
                    {
                        name: "fds",
                        image: storageimages.fdscontroller,
                        ports: [
                            {
                                containerPort: storageconfigs.serviceDefn.fds_svc.controller.port,
                            },
                        ],
                        livenessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: storageconfigs.serviceDefn.fds_svc.controller.port,
                            },
                        },
                        readinessProbe: {
                            httpGet: {
                                path: "/healthz",
                                port: storageconfigs.serviceDefn.fds_svc.controller.port,
                            },
                        },
                        volumeMounts:
                            fdsVolumeMounts,
                        env:
                            fdsEnvironmentVars,
                    } + configs.ipAddressResourceRequest,
                    {
                        // Pump prometheus metrics to argus.
                        name: "sfms",
                        image: storageimages.sfms,
                        command: [
                            "/opt/sfms/bin/sfms",
                        ],
                        args: [
                            "-j",
                            "prometheus",
                        ],
                        env: storageutils.sfms_environment_vars(storageconfigs.serviceDefn.fds_svc.name),
                    },
                    storageutils.poddeleter_podspec(storageimages.maddogpoddeleter),
                ]),
                volumes:
                    podVolumes,
                nodeSelector: if configs.estate != "prd-skipper" then {
                    master: "true",
                } else {},
            },
        },
    } + storageutils.revisionHistorySettings,
} else "SKIP"
