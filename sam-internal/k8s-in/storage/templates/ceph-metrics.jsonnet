local configs = import "config.jsonnet";
local storageimages = (import "storageimages.jsonnet") + { templateFilename:: std.thisFile };
local storageutils = import "storageutils.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

local enabledEstates = std.set([
    "prd-sam_storage",
    "prd-sam",
    "xrd-sam",
]);

if std.setMember(configs.estate, enabledEstates) then
{
    apiVersion: "v1",
    kind: "List",
    metadata: {},
    items: [
        {
        local escapedMinionEstate = storageutils.string_replace(minionEstate, "_", "-"),
        local cephClusterName = "ceph-" + escapedMinionEstate,
        local cephClusterNamespace = (if configs.estate == "prd-sam_storage" then cephClusterName else "legostore"),

        apiVersion: "extensions/v1beta1",
        kind: "Deployment",
        metadata: {
            name: "ceph-metrics",
            namespace: cephClusterNamespace,
            labels: {
                team: "legostore",
                cloud: "storage",
            },
        },
        spec: {
            replicas: 1,
            template: {
                metadata: {
                    labels: {
                    app: "ceph-metrics",
                    team: "legostore",
                    cloud: "storage",
                    },
                },
                spec: {
                    nodeSelector: {
                        pool: storageconfigs.cephMetricsPool,
                    },
                    volumes: [
                    {
                        name: "kubernetes",
                        hostPath: {
                            path: "/etc/kubernetes",
                        },
                    },
                    {
                        name: "ceph-conf",
                        emptyDir: {},
                    },
                    {
                        name: "key-conf",
                        secret: {
                            secretName: "ceph-client-key",
                        },
                    },
                    {
                        name: "ceph-cluster-conf",
                        configMap: {
                            name: "ceph-cluster",
                        },
                    },
                    ],
                    containers: [
                    {
                        name: "sfms",
                        image: storageimages.sfms,
                        imagePullPolicy: "IfNotPresent",
                        command: [
                            "/opt/sfms/bin/sfms",
                        ],
                        args: [
                            "-j",
                            "ceph_mon",
                        ],
                        ports: [
                            {
                                name: storageconfigs.serviceDefn.ceph_metrics_svc.health["port-name"],
                                containerPort: storageconfigs.serviceDefn.ceph_metrics_svc.health.port,
                                protocol: "TCP",
                            },
                        ],
                        volumeMounts: [
                            {
                                name: "ceph-conf",
                                mountPath: "/etc/ceph",
                            },
                        ],
                        env: storageutils.sfms_environment_vars(storageconfigs.serviceDefn.ceph_metrics_svc.name) +
                        if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam" then
                        [
                            {
                                name: "MC_ZK_SERVERS",
                                value: storageconfigs.perEstate.sfstore.zkVIP[configs.estate],
                            },
                            {
                                name: "MC_PORT",
                                value: std.toString(storageconfigs.serviceDefn.ceph_metrics_svc.health.port),
                            },
                        ]
                        else [],
                    },
                    {
                        name: "configwatcher",
                        image: storageimages.configwatcher,
                        imagePullPolicy: "IfNotPresent",
                        args: [
                            "-ceph-key-config-dir=/etc/ceph-metrics/key-config",
                            "-ceph-cluster-config-dir=/etc/ceph-metrics/ceph-cluster-config",
                            "-ceph-config-dir=/etc/ceph",
                        ],
                        volumeMounts: [
                            {
                                name: "ceph-conf",
                                mountPath: "/etc/ceph",
                            },
                            {
                                name: "key-conf",
                                mountPath: "/etc/ceph-metrics/key-config",
                                readOnly: true,
                            },
                            {
                                name: "ceph-cluster-conf",
                                mountPath: "/etc/ceph-metrics/ceph-cluster-config",
                                readOnly: true,
                            },
                            {
                                name: "kubernetes",
                                mountPath: "/etc/kubernetes",
                            },
                        ],
                    },
                    ],
                },
            },
        } + storageutils.revisionHistorySettings,
        }
        for minionEstate in storageconfigs.cephEstates[configs.estate]
    ],
}
else "SKIP"
