local configs = import "config.jsonnet";
local flowsnake_images = (import "flowsnake_images.jsonnet") + { templateFilename:: std.thisFile };
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

if !std.objectHas(flowsnake_images.feature_flags, "spark_op_metrics") then
"SKIP"
else
configs.deploymentBase("flowsnake") {
  local label_node = self.spec.template.metadata.labels,
  metadata: {
    labels: {
        service: "prometheus-scraper",
    },
    name: "prometheus-scraper",
    namespace: "flowsnake",
  },
  spec+: {
    replicas: 1,
    minReadySeconds: 15,
    selector: {
      matchLabels: {
        service: label_node.service,
      },
    },
    template: {
      metadata: {
        labels: {
          apptype: "monitoring",
          service: "prometheus-scraper",
          flowsnakeOwner: "dva-transform",
          flowsnakeRole: "PrometheusScraper",
        },
      },
      spec: {
        serviceAccountName: "prometheus-scraper",
        containers: [
          {
            args: [
              "--config.file=/etc/config/prometheus.json",
              "--storage.tsdb.path=/prometheus-storage",
              "--web.external-url=http://localhost/",
            ] + if std.objectHas(flowsnake_images.feature_flags, "spark_op_metrics") then [
              "--web.enable-lifecycle",
            ] else [],
            image: flowsnake_images.prometheus_scraper,
            name: "prometheus",
            ports: [
              {
                containerPort: 9090,
              },
            ],
            volumeMounts: [
              {
                mountPath: "/prometheus-storage",
                name: "prometheus-storage-volume",
              },
              {
                mountPath: "/etc/config",
                name: "prometheus-server-conf",
              },
            ],
            livenessProbe: {
              httpGet: {
                path: "/metrics",
                port: 9090,
                scheme: "HTTP",
              },
              initialDelaySeconds: 30,
              periodSeconds: 10,
            },
          },
          {
            args: [
              "--serviceName=flowsnake",
              "--subserviceName=NONE",
              "--tagDefault=superpod:NONE",
              "--tagDefault=datacenter:" + kingdom,
              "--tagDefault=estate:" + estate,
              "--batchSize=512",
              "--funnelUrl=" + flowsnake_config.funnel_endpoint,
            ],
            image: flowsnake_images.funnel_writer,
            name: "funnel-writer",
            ports: [
              {
                containerPort: 8000,
              },
            ],
            volumeMounts: [
              {
                mountPath: "/prometheus-storage",
                name: "prometheus-storage-volume",
              },
            ],
            livenessProbe: {
              httpGet: {
                path: "/",
                port: 8000,
                scheme: "HTTP",
              },
              initialDelaySeconds: 30,
              periodSeconds: 10,
            },
          },
        ],
        restartPolicy: "Always",
        volumes: [
          {
            name: "prometheus-server-conf",
              configMap: {
                name: "prometheus-server-conf",
              },
          },
          {
            name: "prometheus-storage-volume",
            emptyDir: {
              medium: "Memory",
            },
          },
        ],
      },
    },
  },
}
