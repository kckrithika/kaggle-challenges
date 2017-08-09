local configs = import "config.jsonnet";

if configs.estate == "prd-samtest" then {
    "apiVersion": "v1",
    "kind": "Namespace",
    "metadata": {
        "name": "idc"
    }
} else "SKIP"
