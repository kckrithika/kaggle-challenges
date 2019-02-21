local configs = import "config.jsonnet";
# local svcPort = (if configs.estate == "prd-samtest" then 7020 else 7035);

# Temporarily kept for both prd-sam and prd-samtest.
# Once the issue to specify name of port in Manifest loadBalancers (Service)
# (https://gus.lightning.force.com/lightning/r/ADM_Work__c/a07B0000006DaQvIAK/view) is fixed, we should remove this Service from internal pipeline.

# This is almost exactly how a Service spec looks like when created by SAM Manifest 'loadBalancers' section.
# Skipped the 'externalIps', but it's manually verified in prd-sam that doesn't affect Istio flows.
if configs.kingdom == "prd" then
{
  apiVersion: "v1",
  kind: "Service",
  metadata: {
    name: "istio-shipping-mixed-istio-to-sherpa",
    namespace: "service-mesh",
  },
  spec: {
    externalTrafficPolicy: "Cluster",
    ports: [
      {
        name: "grpc-shipping",
        port: 7443,
        protocol: "TCP",
        targetPort: 7443,
      },
    ],
    selector: {
      sam_app: "istio-shipping-mixed-istio-to-sherpa",
      sam_function: "istio-shipping-mixed-istio-to-sherpa",
    },
    sessionAffinity: "None",
    type: "NodePort",
  },
  status: {
    loadBalancer: {
    },
  },
} else "SKIP"
