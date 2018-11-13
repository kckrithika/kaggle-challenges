{
local configs = import "config.jsonnet",

hostName: "mysql.csc-sam." + configs.estate + ".prd.slb.sfdc.net",
readOnlyHostName: "mysql-read.sam-system",
readWriteHostName: "mysql-ss-0.mysql-service.sam-system",
userName: "root",
visibilityDBName: if configs.estate == "prd-samdev" then "sam_kube_resource_test" else "sam_kube_resource",
}
