{
local configs = import "config.jsonnet",

readOnlyHostName: "mysql-inmem-read.sam-system.prd-sam.prd.slb.sfdc.net",
readWriteHostName: "mysql-inmem-0.mysql-inmem-service.sam-system",
visibilityDBName: "sam_kube_resource",
}
