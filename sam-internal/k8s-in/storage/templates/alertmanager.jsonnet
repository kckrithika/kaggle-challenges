local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then {
    apiVersion: "extensions/v1beta1",
    kind: "Deployment",
    metadata: {
        name: "alertmanager",
        namespace: "sam-system",
    },
    spec: {
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
                ],
            },
        },
    },
} else "SKIP"
