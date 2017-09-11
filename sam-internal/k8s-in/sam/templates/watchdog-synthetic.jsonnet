local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = import "samimages.jsonnet";

{
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
                  # Please add all new flags and snooze instances to ../configs-sam/watchdog-config.jsonnet
                  "ports": [
                      {
                      "name": "synthetic",
                      "containerPort": 8083
                      }
                  ],
                  "env": [
                     configs.kube_config_env,
                  ],
                  "image": samimages.hypersam,
                  "name": "watchdog-synthetic",
                  "volumeMounts": configs.cert_volume_mounts + [
                     {
                        "mountPath": "/test",
                        "name": "test"
                     },
                     {
                        "mountPath": "/_output",
                        "name": "output"
                     },
                     configs.kube_config_volume_mount,
                     configs.cert_volume_mount,
                     configs.config_volume_mount,
                  ]
               }
            ],
            "hostNetwork": true,
            "nodeSelector": {
               "pool": configs.estate
            },
            "volumes": configs.cert_volumes + [
               configs.cert_volume,
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
               configs.kube_config_volume,
               configs.config_volume("watchdog"),
            ]
         }
      }
   }
}   

