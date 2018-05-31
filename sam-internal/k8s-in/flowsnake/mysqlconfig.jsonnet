{
local configs = import "config.jsonnet",
local flowsnake_config = import "flowsnake_config.jsonnet",

hostName: "mysql.flowsnake.prd-sam.prd.slb.sfdc.net",
userName: "root",
visibilityDBName: if flowsnake_config.is_test then "kube_resource_test" else "kube_resource",
}
