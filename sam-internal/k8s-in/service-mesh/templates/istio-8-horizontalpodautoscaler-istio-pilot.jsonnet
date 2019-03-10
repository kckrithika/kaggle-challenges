# Auto-generated file. Do not modify manually. Check README.md.
local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
{
  apiVersion: "autoscaling/v2beta1",
  kind: "HorizontalPodAutoscaler",
  metadata: {
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
    name: "istio-pilot",
  },
  spec: {
    maxReplicas: 5,
    metrics: [
      {
        resource: {
          name: "cpu",
          targetAverageUtilization: 80,
        },
        type: "Resource",
      },
    ],
    minReplicas: 1,
    scaleTargetRef: {
      apiVersion: "apps/v1beta1",
      kind: "Deployment",
      name: "istio-pilot",
    },
  },
}
