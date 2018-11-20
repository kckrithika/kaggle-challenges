local configs = import "config.jsonnet";
local flowsnake_config = import "flowsnake_config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };

if flowsnake_config.kubedns_synthetic_requests then
configs.deploymentBase("flowsnake") {
  local label_node = self.spec.template.metadata.labels,
  metadata: {
    name: "synthetic-dns-check",
    namespace: "flowsnake",
  },
  spec+: {
    replicas: flowsnake_config.kubedns_synthetic_requests_config.replicas,
    selector: {
      matchLabels: {
        name: label_node.name,
      },
    },
    template: {
      metadata: {
        labels: {
          name: "synthetic-dns-check",
          flowsnakeOwner: "dva-transform",
          flowsnakeRole: "FlowsnakeSyntheticDnsCheck",
        },
      },
      spec: {
        containers: [
          {
            name: "dig-kubedns",
            image: flowsnake_images.jdk8_base,
            command: ["/bin/sh", "/var/run/check-dns/check-dns.sh", "dig_kubedns", std.toString(flowsnake_config.kubedns_synthetic_requests_config.rate) ],
            volumeMounts: [
              {
                name: "etc",
                mountPath: "/hostetc",
                readOnly: true,
              },
              {
                name: "check-dns",
                mountPath: "/var/run/check-dns",
                readOnly: true,
              },
            ],
          },
        ],
        volumes: [
          {
            name: "etc",
            hostPath: {
              path: "/etc",
            },
          },
          {
            name: "check-dns",
            configMap: {
              name: "synthetic-dns-check",
            },
          },
        ],
        restartPolicy: "Always",
      },
    },
  },
} else "SKIP"
