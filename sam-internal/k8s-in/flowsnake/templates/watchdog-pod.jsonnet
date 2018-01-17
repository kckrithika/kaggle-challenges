local configs = import "config.jsonnet";
local flowsnakeimage = import "flowsnake_images.jsonnet";
{
  kind: "Deployment",
   spec: {
       replicas: 1,
       template: {
           spec: {
               hostNetwork: true,
               containers: [
                   {
                       name: "watchdog-pod",
                       image: flowsnakeimage.watchdog,
                       command: [
                           "/sam/watchdog",
                           "-role=POD",
                           "-watchdogFrequency=60s",
                           "-alertThreshold=300s",
                           "-podNamespacePrefixWhitelist=default,flowsnake-,kube",
                           "-emailFrequency=6m",
                           "-timeout=2s",
                           "-funnelEndpoint=" + configs.funnelVIP,
                           "-rcImtEndpoint=" + configs.rcImtEndpoint,
                           "-smtpServer=" + configs.smtpServer,
                           "-sender=vgiridaran@salesforce.com",
                           "-recipient=vgiridaran@salesforce.com",
                           "-email-subject-prefix=FLOWSNAKEWD",
                           "-hostsConfigFile=/data/hosts/hosts.json",
                           "-metricsService=flowsnake",
                           "-tlsEnabled=true",
                           "-caFile=/data/certs/ca.crt",
                           "-keyFile=/data/certs/hostcert.key",
                           "-certFile=/data/certs/hostcert.crt",
                       ],
                       volumeMounts: [
                           {
                               mountPath: "/data/certs",
                               name: "certs",
                           },
                           {
                               mountPath: "/config",
                               name: "config",
                           },
                           {
                               mountPath: "/data/hosts",
                               name: "hosts",
                           },
                       ],
                       env: [
                       {
                           name: "KUBECONFIG",
                           value: "/config/kubeconfig",
                       },
                       ],
                   },
               ],
               volumes: [
                   {
                       hostPath: {
                           path: "/data/certs",
                       },
                       name: "certs",
                   },
                   {
                       hostPath: {
                           path: "/etc/kubernetes",
                       },
                       name: "config",
                   },
                   {
                       configMap: {
                           name: "sfdchosts",
                       },
                       name: "hosts",
                   },
               ],
           },
           metadata: {
              labels: {
                  apptype: "monitoring",
                  name: "watchdog-pod",
              },
          },
       },
      selector: {
          matchLabels: {
              name: "watchdog-pod",
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
