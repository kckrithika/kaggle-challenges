# Creates a container that runs a scrip to clean up the /cowdata directory by removing stale containers and images
# see GUS ticket W-5920222, https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006UghEIAS/view
# we just want to run
#   docker system prune -af && docker load -i /opt/kubernetes/images/etcd.tar
# run every week, ie 604800 seconds

local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local hosts = import "configs/hosts.jsonnet";

if configs.estate == "prd-samtest" then {
    kind: "DaemonSet",
    metadata: {
        name: "docker-cleaner",
        namespace: "kube-system",
        labels: {
            "addonmanager.kubernetes.io/mode": "Reconcile",
            "k8s-app": "docker-cleaner",
            "kubernetes.io/cluster-service": "true",
        } + configs.ownerLabel.sam,
        spec: {
            revisionHistoryLimit: 2,
            selector: {
                matchLabels: {
                    "k8s-app": "docker-cleanup",
                },
            },
            spec: {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                containers: [
                    {
                        name: "docker-cleanup",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-devmvp/tkuznets/docker:dind",
                        command:
                        -"/bin/sh"
                        - "-c"
                        - '|
                          while true
                          do
                            docker system prune -af && docker load -i /opt/kubernetes/images/etcd.tar
                            sleep 604800
                          done',
                        volumeMounts: configs.filter_empty([
                            {
                                name: "images",
                                mountPath: "/opt/kubernetes/images",
                            },
                        ]),
                    } + configs.ipAddressResourceRequest,
                ],
                volumes: configs.filter_empty([
                    {
                        hostPath: {
                            path: "/opt/kubernetes/images/",
                        },
                        name: "images",
                    },
                ]),
            },

            metadata: {
                labels: {
                    name: "docker-cleanup",
                } + configs.ownerLabel.sam,
            },
        },
    },
} else "SKIP"
