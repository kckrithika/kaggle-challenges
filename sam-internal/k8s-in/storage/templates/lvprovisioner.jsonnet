local configs = import "config.jsonnet";
local storageimages = import "storageimages.jsonnet";
local storageconfigs = import "storageconfig.jsonnet";

if configs.estate == "disabled" then {
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        name: "pvprovisioner",
        namespace: "localpv",
    },
    spec: {
        template: {
            metadata: {
                labels: {
                     name: "pvprovisioner",
                },
            },
            spec: {
                volumes: configs.filter_empty([
                    configs.maddog_cert_volume,
                    configs.cert_volume,
                    configs.kube_config_volume,
                    {
                        name: "localdisks",
                        hostPath: {
                            path: "/mnt/lvhdd",
                        },
                    },
                    {
                        name: "homedir",
                        hostPath: {
                            path: "/root",
                        },
                    },
                ]),
                nodeSelector: {
                    pool: configs.estate,
                },
                containers: [
                    {
                         name: "local-pv-provisioner",
                         image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/foundation/local_pv_provisioner:0.1",
                         imagePullPolicy: "Always",

                         securityContext: {
                             privileged: true,
                         },

                         volumeMounts: configs.filter_empty([
                             configs.maddog_cert_volume_mount,
                             configs.cert_volume_mount,
                             configs.kube_config_volume_mount,
                             {
                                 name: "localdisks",
                                 mountPath: "/mnt/lvhdd",
                             },
                             {
                                 name: "homedir",
                                 mountPath: "/root",
                             },
                         ]),

                         env: [
                             configs.kube_config_env,

                             {
                                name: "LV_NODE_NAME",
                                valueFrom: {
                                      fieldRef: {
                                          fieldPath: "spec.nodeName",
                                      },
                                  },
                             },

                             {
                                 name: "LV_STORAGE_CLASS_NAME",
                                 value: "hdd",
                             },

                             {
                                 name: "LV_ROOT_PATH",
                                 value: "/mnt/lvhdd",
                             },
                          ],
                    },
                ],
            },
         },
    },
} else "SKIP"
