{
local configs = import "config.jsonnet",

readOnlyHostName: "mysql-read.sam-system",
readWriteHostName: "mysql-ss-0.mysql-service.sam-system",
visibilityDBName: "sam_kube_resource",
}
