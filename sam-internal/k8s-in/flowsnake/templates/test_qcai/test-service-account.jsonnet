local flowsnakeconfig = import "flowsnake_config.jsonnet";

if flowsnakeconfig.is_test then
{
   apiVersion: "v1",
   kind: "ServiceAccount",
   metadata: {
       name: "test-account1",
       namespace: "test-qcai"
   },
} else "SKIP"
