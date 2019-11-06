local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then
{
   "apiVersion": "v1",
   "kind": "ServiceAccount",
   "metadata": {
      "annotations": {
         "manifestctl.sam.data.sfdc.net/swagger": "disable"
      },
      "labels": {
         "app": "istio-ingressgateway",
         "release": "istio"
      },
      "name": "istio-ingressgateway-service-account",
      "namespace": "slb"
   }
} else "SKIP"