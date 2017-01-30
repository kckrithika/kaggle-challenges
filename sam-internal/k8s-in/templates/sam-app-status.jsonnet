local configs = import "config.jsonnet";
if configs.estate == "prd-samdev" || configs.estate == "prd-sam" then {
   "apiVersion": "extensions/v1beta1",
    "kind": "ThirdPartyResource",
    "metadata": {
      "name": "sam-app-status.salesforce.com"
    },
    "description": "A specification of a SAM application",
    "versions": [
      {
        "name": "v1"
      }
    ]
} else "SKIP"
