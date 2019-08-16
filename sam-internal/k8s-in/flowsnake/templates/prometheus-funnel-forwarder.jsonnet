local flowsnake_images = (import "flowsnake_images.jsonnet");
local flowsnake_config = import "flowsnake_config.jsonnet";
local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");


if "central_prometheus_forwarder" in flowsnake_images.feature_flags then
{
  apiVersion: "v1",
  kind: "List",
  metadata: {},
  items: [
    {
      kind: "Deployment",
      apiVersion: "extensions/v1beta1",
      metadata: {
        namespace: "flowsnake",
        name: "prometheus-funnel-forwarder-deployment",
        labels: {
          apptype: "monitoring",
          service: "prometheus-funnel-forwarder",
          name: "prometheus-funnel-forwarder-deployment",
        },
      },
      spec: {
        replicas: 2,
        selector: {
          matchLabels: {
            apptype: "monitoring",
            service: "prometheus-funnel-forwarder",
          },
        },
        template: {
          metadata: {
            labels: {
              apptype: "monitoring",
              service: "prometheus-funnel-forwarder",
            },
          },
          spec: {
            restartPolicy: "Always",
            serviceAccountName: "default",
            containers: [
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
                name: "forwarder",
                ports: [
                  {
                    containerPort: 8000,
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
          },
        },
      },
    },
    {
      kind: "Service",
      apiVersion: "v1",
      metadata: {
        name: "prometheus-funnel-forwarder",
        namespace: "flowsnake",
      },
      spec: {
        type: "ClusterIP",
        sessionAffinity: "None",
        selector: {
          service: "prometheus-funnel-forwarder",
        },
        ports: [
          {
            name: "http",
            port: 80,
            targetPort: 8000,
          },
        ],
      },
    },
  ],
}
else
"SKIP"
