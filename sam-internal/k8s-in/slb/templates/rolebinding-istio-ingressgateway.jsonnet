local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then
{
   "apiVersion": "rbac.authorization.k8s.io/v1",
   "kind": "RoleBinding",
   "metadata": {
      "annotations": {
         "manifestctl.sam.data.sfdc.net/swagger": "disable"
      },
      "name": "istio-ingressgateway-sds",
      "namespace": "slb"
   },
   "roleRef": {
      "apiGroup": "rbac.authorization.k8s.io",
      "kind": "Role",
      "name": "istio-ingressgateway-sds"
   },
   "subjects": [
      {
         "kind": "ServiceAccount",
         "name": "istio-ingressgateway-service-account",
         "namespace": "slb"
      }
   ]
} else "SKIP"