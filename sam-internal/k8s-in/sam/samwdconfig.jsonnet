{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local configs = import "config.jsonnet",

# [thargrove] TODO: This is not the ideal setup for email.  We are specifying the base email in the configMap,
# but since the configMap is shared across all checkers, we use an extra flag to add pagerDuty.  But
# that flag also needs to contain the base emails, so they have been moved here.  Going with this approach
# for now, but looking to tweak flags to watchdogs to let us move this back to the configMap (and turn on/off
# pager duty with a simple boolean.

recipient: (
        if configs.estate == "prd-sdc" then "sdn@salesforce.com"
        else if configs.estate == "prd-sam_storage" then "storagefoundation@salesforce.com"
        else if configs.estate == "prd-samdev" then ""
        else if configs.estate == "prd-samtest" then ""
        else if configs.kingdom == "prd" then "sam-test-alerts@salesforce.com"
        else "sam-alerts@salesforce.com"
),
laddr: (if configs.estate == "prd-sam" then "0.0.0.0:8063" else "0.0.0.0:8083"),
syntheticPort: (if configs.estate == "prd-sam" then 8063 else 8083),
pagerduty_args: (if (configs.estate != "prd-sdc" && configs.estate != "prd-sam_storage" && configs.estate != "prd-samdev" && configs.estate != "prd-samtest") then [
  "-recipient=" + $.recipient + "," + "csc-sam-sam-email.mbaphr21@salesforce.pagerduty.com",
] else []),

shared_args: configs.filter_empty([
    "-timeout=2s",
    "-funnelEndpoint=" + configs.funnelVIP,
    "--config=/config/watchdog.json",
    configs.sfdchosts_arg,
]),
}
