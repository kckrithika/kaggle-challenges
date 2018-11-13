{
local configs = import "config.jsonnet",

readOnlyHostName: "mysql-read.sam-system",
readWriteHostName: "mysql-ss-0.mysql-service.sam-system",
userName: "root",
visibilityDBName: if configs.estate == "prd-samdev" then "sam_kube_resource_test" else "sam_kube_resource",
}
