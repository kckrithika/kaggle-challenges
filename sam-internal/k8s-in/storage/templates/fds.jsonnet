local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
    "prd-skipper",
    "phx-sam",
]);

local enabledEstatesForPodDeleter = std.set([
    "prd-sam",
    "prd-sam_storage",
    "prd-skipper",
]);

// Init containers for the pod.
local initContainers = [
    storageutils.log_init_container(
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
    // This is to force a resync for fds, since running all .yaml from a folder sometimes leads to
    // things running out of order, this is to allow for faster recovery for cluster creation
    if configs.estate == "prd-skipper" then {
        name: "FDS_MIN_RESYNC_PERIOD",
        value: "3s",
    },
]);

// Volumes available to the pod.
local podVolumes =
    storageutils.log_init_volumes() +
    storageutils.cert_volume();

if std.setMember(configs.estate, enabledEstates) then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "fds-controller",
            team: "storage-foundation",
            cloud: "storage",
        },
        name: "fds-controller-deployment",
        namespace: "sam-system",
    },
    spec: {
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
                    },
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
                        env: storageutils.sfms_environment_vars(storageconfigs.serviceDefn.fds_svc.name) +
                        if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then
                        [
                            {
                                name: "MC_ZK_SERVERS",
                                value: storageconfigs.perEstate.sfstore.zkVIP[configs.estate],
                            },
                            {
                                name: "MC_PORT",
                                value: std.toString(storageconfigs.serviceDefn.fds_svc.controller.port),
                            },
                        ]
                        else [],
                    },
                    if std.setMember(configs.estate, enabledEstatesForPodDeleter) then
                    storageutils.poddeleter_podspec(storageimages.maddogpoddeleter),
                ]),
                volumes:
                    podVolumes,
                nodeSelector: if configs.estate != "prd-skipper" then {
                    master: "true",
                } else {},
            },
        },
    },
} else "SKIP"
