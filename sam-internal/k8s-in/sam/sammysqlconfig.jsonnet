{
local configs = import "config.jsonnet",

readOnlyHostName: "mysql-inmem-service.sam-system.prd-sam.prd.slb.sfdc.net",
readWriteHostName: "mysql-inmem-service.sam-system.prd-sam.prd.slb.sfdc.net",
visibilityDBName: "sam_kube_resource",
}
