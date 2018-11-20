local flowsnake_config = import "flowsnake_config.jsonnet";
if flowsnake_config.kubedns_synthetic_requests then
{
  kind: "ConfigMap",
  apiVersion: "v1",
  metadata: {
    name: "synthetic-dns-check",
    namespace: "flowsnake",
  },
  data: {
    "check-dns.sh": (importstr "synthetic-dns-check-script.sh"),
    "host-data": (importstr "synthetic-dns-check-host-data.txt"),
  },
}
else "SKIP"
