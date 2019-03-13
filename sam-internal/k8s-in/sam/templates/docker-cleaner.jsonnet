# Creates a container that runs a scrip to clean up the /cowdata directory by removing stale containers and images
# see GUS ticket W-5920222, https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006UghEIAS/view
# we just want to run
#   docker system prune -af && docker load -i /opt/kubernetes/images/etcd.tar
# run every week, ie 604800 seconds

local configs = import "config.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };
local hosts = import "configs/hosts.jsonnet";

if configs.estate == "prd-samdev" then {
    kind: "Deployment",
    spec: {
        template: {
            spec: {
                securityContext: {
                    runAsUser: 0,
                    fsGroup: 0,
                },
                containers: [
                    {
                        name: "docker-cleaner",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-devmvp/tkuznets/docker:dind",
                        command: [
                                  "sh",
                                  "-c",
|||
                                  while true
                                  do
                                    usedCowdataPercent=`df -h /cowdata/ | tail -1 | awk '{print $5}'  | cut -f 1 -d %`
                                    if [ $usedCowdataPercent -gt 75 ]; then
                                      echo "used $usedCowdataPercent % in /cowdata, starting cleaning"
                                      docker system prune -af && docker load -i /opt/kubernetes/images/etcd.tar
                                    else
                                      echo "only used $usedCowdataPercent %, not doing cleaning"
                                    fi
                                    echo "about to sleep"
                                    sleep 604800
                                    echo "done sleeping"
                                  done
|||,
                        ],
                        volumeMounts: configs.filter_empty([
                                    {
                                        name: "images",
                                        mountPath: "/opt/kubernetes/images",
                                    },
                                    {
                                        name: "docker-socket",
                                        mountPath: "/var/run/docker.sock",
                                    },
                        ]),
                    },
                ],
                nodeSelector: {
                    "kubernetes.io/hostname": "shared0-samdevcompute1-1-prd.eng.sfdc.net",
                },
                volumes: configs.filter_empty([
                    {
                        hostPath: {
                            path: "/opt/kubernetes/images/",
                        },
                        name: "images",
                    },
                    {
                        hostPath: {
                            path: "/var/run/docker.sock",
                        },
                        name: "docker-socket",
                    },
                ]),
            },
            metadata: {
                labels: {
                    name: "docker-cleaner",
                } + configs.ownerLabel.sam,
            },
        },
    },
    apiVersion: "extensions/v1beta1",
    metadata: {
        name: "docker-cleaner",
        namespace: "sam-system",
        labels: {
            name: "docker-cleaner",
        } + configs.ownerLabel.sam,
    },
} else "SKIP"
