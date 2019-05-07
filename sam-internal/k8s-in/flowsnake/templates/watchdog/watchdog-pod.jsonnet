local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local certs_and_kubeconfig = import "certs_and_kubeconfig.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
local watchdog = import "watchdog.jsonnet";
local utils = import "util_functions.jsonnet";

if !watchdog.watchdog_enabled then
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
                       name: "watchdog-pod",
                       image: flowsnake_images.watchdog,
                       command: [
                           "/sam/watchdog",
                           "-role=POD",         # TODO: Add this role into the enum in sam/sam framework.go
                           "-watchdogFrequency=60s",
                           "-alertThreshold=300s",
                           "-emailFrequency=" + watchdog.watchdog_email_frequency_kuberesources,	# TODO: Probably adopt the frequency for kuberesources, but need to confirm whether it's proper (current value is 72h, which is probably too infrequent)
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
               certs_and_kubeconfig.platform_cert_volume,
           },
           metadata: {
              labels: {
                  apptype: "monitoring",
                  name: "watchdog-pod",
                  flowsnakeOwner: "dva-transform",
                  flowsnakeRole: "WatchdogPod",
              },
          },
       },
   },
  apiVersion: "extensions/v1beta1",
  metadata: {
      labels: {
          name: "watchdog-pod",
      },
      name: "watchdog-pod",
      namespace: "flowsnake",
  },
}
