local configs = import "config.jsonnet";

if configs.estate == "prd-sam" then
{
   "apiVersion": "rbac.authorization.k8s.io/v1",
   "kind": "Role",
   "metadata": {
      "annotations": {
         "manifestctl.sam.data.sfdc.net/swagger": "disable"
      },
      "name": "istio-ingressgateway-sds"
   },
   "rules": [
      {
         "apiGroups": [
            ""
         ],
         "resources": [
            "secrets"
         ],
         "verbs": [
            "get",
            "watch",
            "list"
         ]
      }
   ]
} else "SKIP"
