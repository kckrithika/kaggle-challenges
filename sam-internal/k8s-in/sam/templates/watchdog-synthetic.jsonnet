local configs = import "config.jsonnet";
local samwdconfig = import "samwdconfig.jsonnet";
local samimages = (import "samimages.jsonnet") + { templateFilename:: std.thisFile };

{
   apiVersion: "extensions/v1beta1",
   kind: "Deployment",
   metadata: {
      labels: {
         name: "watchdog-synthetic",
      },
      name: "watchdog-synthetic",
      namespace: "sam-system",
   },
   spec: {
      replicas: 1,
      selector: {
         matchLabels: {
            name: "watchdog-synthetic",
         },
      },
      template: {
         metadata: {
            labels: {
               apptype: "monitoring",
               name: "watchdog-synthetic",
            },
         },
         spec: {
            containers: [
               {
                  command: [
                     "/sam/watchdog",
                     "-role=SYNTHETIC",
                     "-watchdogFrequency=180s",
                     "-alertThreshold=1h",
                     "-emailFrequency=12h",
                     "-laddr=" + samwdconfig.laddr,
                     "-maxdeploymentduration=5m",
                     "-imageName=" + samimages.hypersam,
                  ]
                  + samwdconfig.shared_args,
                  ports: [
                      {
                      name: "synthetic",
                      containerPort: samwdconfig.syntheticPort,
                      },
                  ],
                  env: [
                     configs.kube_config_env,
                  ],
                  image: samimages.hypersam,
                  name: "watchdog-synthetic",
                  volumeMounts: configs.filter_empty([
                     configs.sfdchosts_volume_mount,
                     configs.maddog_cert_volume_mount,
                     {
                        mountPath: "/test",
                        name: "test",
                     },
                     {
                        mountPath: "/_output",
                        name: "output",
                     },
                     configs.kube_config_volume_mount,
                     configs.cert_volume_mount,
                     configs.config_volume_mount,
                  ]),
               },
            ],
            hostNetwork: true,
            nodeSelector: {
            } +
            if configs.kingdom == "prd" then {
                  master: "true",
            } else {
                  pool: configs.estate,
            },
            volumes: configs.filter_empty([
               configs.sfdchosts_volume,
               configs.maddog_cert_volume,
               configs.cert_volume,
               {
                  hostPath: {
                     path: "/manifests",
                  },
                  name: "sfdc-volume",
               },
               {
                  emptyDir: {},
                  name: "test",
               },
               {
                  emptyDir: {},
                  name: "output",
               },
               configs.kube_config_volume,
               configs.config_volume("watchdog"),
            ]),
         },
      },
   },
}
