local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";
local isEstateNotSkipper = configs.estate != "prd-skipper";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam",
    "prd-skipper",
]);

local masterNodeSelector =
    if isEstateNotSkipper then {
        master: "true",
    }
    else {};

// Environment variables for the Local Provisioner container.
local cephOpEnvironmentVars =
        if isEstateNotSkipper then configs.filter_empty([configs.kube_config_env])
        else [
        {
            name: "MIN_OSD_VOL_SIZE",
            value: "5Gi",
        },
        {
            name: "MIN_MON_VOL_SIZE",
            value: "5Gi",
        },
        {
            name: "DEV_MODE",
            value: "YEs",
        },
        ];

//Environment variables for the madkub client init and refresher container.
local madkubOpEnvVars = if isEstateNotSkipper && storageimages.phase == "1" then [
        {
            name: "MADKUB_IMAGE",
            value: storageimages.madkub_image_path,
        },
        {
            name: "MADDOG_ENDPOINT",
            value: configs.maddogEndpoint,
        },
        {
            name: "MADKUB_ENDPOINT",
            value: "$(MADKUBSERVER_SERVICE_HOST):32007",
        },
        {
            name: "FUNNEL_ENDPOINT",
            value: configs.funnelVIP,
        },
        {
            name: "MC_ESTATE",
            value: configs.estate,
        },
        {
            name: "MC_KINGDOM",
            value: configs.kingdom,
        },
        ] else [];


if std.setMember(configs.estate, enabledEstates) then configs.deploymentBase("storage") {
    metadata: {
        labels: {
            name: "cephoperator",
            team: "legostore",
            cloud: "storage",
        } + configs.ownerLabel.storage,
        name: "cephoperator-deployment",
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
                    name: "cephoperator",
                    team: "legostore",
                    cloud: "storage",
                },
            },
            spec: {
                initContainers: [
                    {} +
                    storageimages.log_init_container(
                        storageimages.loginit,
                        "ceph-operator",
                        0,
                        0,
                        "root"
                    ),
                ],
                containers: [
                    {
                        name: "cephoperator",
                        image: storageimages.cephoperator,
                        volumeMounts:
                            storageutils.log_init_volume_mounts()
                            + storageutils.cert_volume_mounts(),
                        env: cephOpEnvironmentVars + madkubOpEnvVars + [
                            {
                                name: "K8S_PLATFORM",
                                value: configs.estate,
                            },
                            {
                                name: "CEPH_INIT_CONTAINER",
                                value: storageimages.loginit,
                            },
                            {
                                name: "CEPH_DAEMON_IMAGE_PATH",
                                value: storageimages.cephdaemon_image_path,
                            },

                        ],
                    } + configs.ipAddressResourceRequest,
                    {
                        // Pump prometheus metrics to argus.
                        name: "sfms",
                        image: storageimages.sfms,
                        command: [
                            "/opt/sfms/bin/sfms",
                        ],
                        args: [
                            "-t",
                            "ajna_with_tags",
                            "-s",
                            "prometheus",
                            "-i",
                            '60',
                        ],
                        env: storageutils.sfms_environment_vars("ceph-operator"),
                    },
                    storageutils.poddeleter_podspec(storageimages.maddogpoddeleter),
                ],
                volumes:
                    storageutils.log_init_volumes()
                    + storageutils.cert_volume(),
                nodeSelector: masterNodeSelector,
            },
        },
    } + storageutils.revisionHistorySettings,
} else "SKIP"
