local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

// Defines the list of estates where this service is enabled.
local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
]);

if std.setMember(configs.estate, enabledEstates) then configs.deploymentBase("storage") {
    metadata: {
        name: "alertmanager",
        namespace: "sam-system",
        labels: {} + configs.ownerLabel.storage,
    },
    spec+: {
        replicas: 1,
        template: {
            metadata: {
                labels: {
                    name: "alertmanager",
                    team: "storage-foundation",
                    cloud: "storage",
                },
            },
            spec: {
                volumes: storageutils.log_init_volumes()
                + configs.filter_empty([
                        configs.maddog_cert_volume,
                        configs.cert_volume,
                        configs.kube_config_volume,
                    ]),
                nodeSelector: {
                    master: "true",
                },
                containers: [
                    {
                        name: "alertmanager",
                        image: storageimages.alertmanager,
                        [if configs.estate == "prd-sam" then "resources"]: configs.ipAddressResource,
                        ports: [
                            {
                                name: storageconfigs.serviceDefn.alert_mgr_svc.alert_hook["port-name"],
                                containerPort: storageconfigs.serviceDefn.alert_mgr_svc.alert_hook.port,
                                protocol: "TCP",
                            },
                            {
                                name: storageconfigs.serviceDefn.alert_mgr_svc.alert_publisher["port-name"],
                                containerPort: storageconfigs.serviceDefn.alert_mgr_svc.alert_publisher.port,
                                protocol: "TCP",
                            },
                        ],
                        volumeMounts:
                            storageutils.log_init_volume_mounts()
                            + configs.filter_empty([
                                configs.maddog_cert_volume_mount,
                                configs.cert_volume_mount,
                                configs.kube_config_volume_mount,
                            ]),
                        env: configs.filter_empty([
                            configs.kube_config_env,
                        ]),
                    },
                    storageutils.poddeleter_podspec(storageimages.maddogpoddeleter),
                ],
            },
        },
    } + storageutils.revisionHistorySettings,
} else "SKIP"
