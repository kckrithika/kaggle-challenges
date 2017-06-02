local configs = import "config.jsonnet";
local wdconfig = import "wdconfig.jsonnet";

if configs.estate == "prd-samdev" || configs.estate == "prd-samtest" then {
   "apiVersion": "extensions/v1beta1",
   "kind": "Deployment",
   "metadata": {
      "labels": {
         "name": "watchdog-synthetic"
      },
      "name": "watchdog-synthetic"
   },
   "spec": {
      "replicas": 1,
      "selector": {
         "matchLabels": {
            "name": "watchdog-synthetic"
         }
      },
      "template": {
         "metadata": {
            "labels": {
               "apptype": "monitoring",
               "name": "watchdog-synthetic"
            }
         },
         "spec": {
            "containers": [
               {
                  "command": [
                     "/sam/watchdog",
                     "-role=SYNTHETIC",
                     "-watchdogFrequency=60s",
                     "-alertThreshold=300s",
                     "-emailFrequency=12h",
                     "-timeout=2s",
                     "-funnelEndpoint=ajna0-funnel1-0-prd.data.sfdc.net:80",
                     "-smtpServer=rd1-mta1-4-sfm.ops.sfdc.net:25",
                     "-sender=sam@salesforce.com",
                     "-recipient=prabh.singh@salesforce.com",
                     "-laddr=0.0.0.0:8083",
                     "-imageName=ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prabh.singh/hypersam:20170515_002025.501bc7e.dirty.prabhsingh-ltm5"
                  ],
                  "ports": [
                      {
                      "name": "synthetic",
                      "containerPort": 8083
                      }
                  ],
                  "env": [
                     {
                        "name": "KUBECONFIG",
                        "value": "/config/kubeconfig"
                     }
                  ],
                  "image": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/prabh.singh/hypersam:20170515_002025.501bc7e.dirty.prabhsingh-ltm5",
                  "name": "watchdog-synthetic",
                  "volumeMounts": [
                     {
                        "mountPath": "/test",
                        "name": "test"
                     },
                     {
                        "mountPath": "/_output",
                        "name": "output"
                     },
                     {
                        "mountPath": "/config",
                        "name": "config"
                     },
                     {
                        "mountPath": "/data/certs",
                        "name": "certs"
                     }
                  ]
               }
            ],
            "hostNetwork": true,
            "nodeSelector": {
               "pool": configs.estate
            },
            "volumes": [
               {
                  "hostPath": {
                     "path": "/data/certs"
                  },
                  "name": "certs"
               },
               {
                  "hostPath": {
                     "path": "/manifests"
                  },
                  "name": "sfdc-volume"
               },
               {
                  "emptyDir": {},
                  "name": "test"
               },
               {
                  "emptyDir": {},
                  "name": "output"
               },
               {
                  "hostPath": {
                     "path": "/etc/kubernetes"
                  },
                  "name": "config"
               }
            ]
         }
      }
   }
} else "SKIP"

