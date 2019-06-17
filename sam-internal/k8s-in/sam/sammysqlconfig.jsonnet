{
local configs = import "config.jsonnet",
dbHostname: "mysql-inmem-service.sam-system." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net",
visibilityDBName: "sam_kube_resource",
}
