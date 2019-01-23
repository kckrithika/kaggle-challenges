local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_test then
{
   apiVersion: "v1",
   kind: "ResourceQuota",
   metadata: {
       name: "compute-resources",
       namespace: "test-qcai"
   },
   spec: {
       hard: {
    pods: "4",
    "requests.cpu": "1",
    "requests.memory": "1Gi",
    "limits.cpu": "2",
    "limits.memory": "2Gi",
    "requests.nvidia.com/gpu": 4 },
    },
} else "SKIP"
