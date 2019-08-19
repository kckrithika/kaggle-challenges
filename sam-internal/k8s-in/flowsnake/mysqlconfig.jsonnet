{
local configs = import "config.jsonnet",
local flowsnake_config = import "flowsnake_config.jsonnet",

hostName: "mysql.flowsnake.svc.cluster.local",
userName: "ssc-prd",
visibilityDBName: "sam_kube_resource",
}
