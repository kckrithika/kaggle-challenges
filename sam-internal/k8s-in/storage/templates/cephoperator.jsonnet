local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageconfigs = import "storageconfig.jsonnet";
local storageutils = import "storageutils.jsonnet";
local isEstateNotSkipper = configs.estate != "prd-skipper";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam",
    "prd-skipper",
    "phx-sam",
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

if std.setMember(configs.estate, enabledEstates) then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        labels: {
            name: "cephoperator",
            team: "legostore",
            cloud: "storage",
        },
        name: "cephoperator-deployment",
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
                    name: "cephoperator",
                    team: "legostore",
                    cloud: "storage",
                },
            },
            spec: {
                initContainers: [
                    {} +
                    storageutils.log_init_container(
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
                        env: cephOpEnvironmentVars + [
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
                    },
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
                ],
                volumes:
                    storageutils.log_init_volumes()
                    + storageutils.cert_volume(),
                nodeSelector: masterNodeSelector,
            },
        },
    },
} else "SKIP"
