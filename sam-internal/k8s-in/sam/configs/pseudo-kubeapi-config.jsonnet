local configs = import "config.jsonnet";
local mysql = import "sammysqlconfig.jsonnet";

if configs.estate == "prd-samtwo" || configs.estate == "prd-samdev" then
std.prune({
       "sql-db-host": "mysql-inmem-service.sam-system." + configs.estate + ".prd.slb.sfdc.net",
       "sql-db-port": 3306,
       "sql-db-name": "sam_kube_resource",
       "sql-db-pass-file": "/var/secrets/pseudo-api",
       "sql-db-user": "pseudo-api",
       "sql-db-resources-table": "k8s_resource",
       v: 4,
       alsologtostderr: true,
       "insecure-port": 7002,
       "passthrough-api-server": "k8sproxy.sam-system." + configs.estate + ".prd.slb.sfdc.net:5000",
       "passthrough-all-cluster": configs.estate,
       "secret-passthrough-namespace": "kube-system",
}) else "SKIP"
