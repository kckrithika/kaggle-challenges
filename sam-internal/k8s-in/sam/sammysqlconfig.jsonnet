{
local configs = import "config.jsonnet",
dbHostname: (if configs.estate == "prd-sam" then "mysql-inmem-service.sam-system.prd-sam.prd.slb.sfdc.net" else if configs.estate == "prd-samtwo" then "mysql-inmem-service.sam-system.prd-samtwo.prd.slb.sfdc.net" else ""),
visibilityDBName: "sam_kube_resource",
}
