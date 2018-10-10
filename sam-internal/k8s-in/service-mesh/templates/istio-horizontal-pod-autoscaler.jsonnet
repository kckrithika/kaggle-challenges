local configs = import "config.jsonnet";

{
  apiVersion: "autoscaling/v2beta1",
  kind: "HorizontalPodAutoscaler",
  metadata: {
    name: "istio-pilot",
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  spec: {
    maxReplicas: 5,
    minReplicas: 1,
    scaleTargetRef: {
      apiVersion: "apps/v1beta1",
      kind: "Deployment",
      name: "istio-pilot",
    },
    metrics: [
      {
        type: "Resource",
        resource: {
          name: "cpu",
          targetAverageUtilization: 80,
        },
      },
    ],
  },
}
