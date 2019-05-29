local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local utils = import "util_functions.jsonnet";


// Disable everywhere for now because too noisy, because at any given time we have failed customer pods.
// Re-enabled as the short-term solution of kube-state-metrics and prometheus pod monitoring
// See https://salesforce.quip.com/UpbkAVHAqMXj and https://salesforce.quip.com/6bpoARusWKWU
if !watchdog.watchdog_enabled || !std.objectHas(flowsnake_images.feature_flags, "watchdog_kuberesources") then
"SKIP"
else
{
  local label_node = self.spec.template.metadata.labels,
  kind: "Deployment",
   spec: {
       replicas: 1,
       selector: {
           matchLabels: {
               name: label_node.name,
               apptype: label_node.apptype,
           },
       },
       template: {
           spec: {
               hostNetwork: true,
               containers: [
                   {
                       name: "watchdog-kuberesources",
                       image: flowsnake_images.watchdog,
                       command: [
                           "/sam/watchdog",
                           "-role=KUBERESOURCES",
                           "-watchdogFrequency=60s",
                           "-alertThreshold=300s",
                           "-emailFrequency=" + watchdog.watchdog_email_frequency_kuberesources,
                           "-shouldBatchMetrics=true",
                           "-maxUptimeSampleSize=5",
                           "-timeout=2s",
                           "-funnelEndpoint=" + flowsnakeconfig.funnel_vip_and_port,
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
                       certs_and_kubeconfig.platform_cert_volumeMounts,
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
                     name: 
                       if std.objectHas(flowsnake_images.feature_flags, "rm_kuberesources_cm")
                       then "watchdog"
                       else "watchdog-kuberesources",
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
               certs_and_kubeconfig.platform_cert_volume,
           },
           metadata: {
              labels: {
                  apptype: "monitoring",
                  name: "watchdog-kuberesources",
                  flowsnakeOwner: "dva-transform",
                  flowsnakeRole: "WatchdogKuberesources",
              },
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
