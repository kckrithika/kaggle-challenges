local flowsnakeimage = import "flowsnake_images.jsonnet";
local flowsnakeconfigmapmount = import "flowsnake_configmap_mount.jsonnet";
{
  kind: "Deployment",
   spec: {
       replicas: 1,
       template: {
           spec: {
               hostNetwork: true,
               containers: [
                   {
                       name: "watchdog-kuberesources",
                       image: flowsnakeimage.watchdog,
                       command: [
                           "/sam/watchdog",
                           "-role=KUBERESOURCES",
                           "-watchdogFrequency=60s",
                           "-alertThreshold=300s",
                           "-emailFrequency=6m",
                           "-shouldBatchMetrics=true",
                           "-maxUptimeSampleSize=5",
                           "-timeout=2s",
                           "-funnelEndpoint=ajna0-funnel1-0-prd.data.sfdc.net:80",
                           "--config=/config/watchdog.json",
                           "--hostsConfigFile=/sfdchosts/hosts.json",
                       ],
                       volumeMounts: [
                         {
                           mountPath: "/sfdchosts",
                           name: "sfdchosts",
                         },
                         {
                           mountPath: "/hostproc",
                           name: "procfs-volume",
                         },
                         {
                           mountPath: "/config",
                           name: "config",
                         },
                         {
                           mountPath: "/kubeconfig",
                           name: "kubeconfig",
                         },
                       ] +
                       flowsnakeconfigmapmount.cert_volumeMounts,
                       env: [
                           {
                               name: "KUBECONFIG",
                               value: "/kubeconfig/kubeconfig-platform",
                           },
                       ],
                   },
               ],
               volumes: [
                 {
                   configMap: {
                     name: "sfdchosts",
                   },
                   name: "sfdchosts",
                 },
                 {
                   hostPath: {
                     path: "/proc",
                   },
                   name: "procfs-volume",
                 },
                 {
                   configMap: {
                     name: "watchdog",
                   },
                   name: "config",
                 },
                 {
                   hostPath: {
                     path: "/etc/kubernetes",
                   },
                   name: "kubeconfig",
                 },
               ] +
               flowsnakeconfigmapmount.cert_volume,
           },
           metadata: {
              labels: {
                  apptype: "monitoring",
                  name: "watchdog-kuberesources",
              },
          },
       },
      selector: {
          matchLabels: {
              name: "watchdog-kuberesources",
          },
      },
   },
  apiVersion: "extensions/v1beta1",
  metadata: {
      labels: {
          name: "watchdog-kuberesources",
      },
      name: "watchdog-kuberesources",
      namespace: "flowsnake",
  },
}
