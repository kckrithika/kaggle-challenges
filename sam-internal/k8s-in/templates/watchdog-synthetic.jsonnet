local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";

if configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "prd-sam" || configs.kingdom == "frf" then {
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
                     "-laddr=0.0.0.0:8083",
                     "-imageName="+samimages.hypersam
                  ]
                  + samwdconfig.shared_args,
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
                  "image": samimages.hypersam,
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

