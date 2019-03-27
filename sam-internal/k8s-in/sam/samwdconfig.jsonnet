{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local configs = import "config.jsonnet",
local utils = import "util_functions.jsonnet",

# [thargrove] TODO: This is not the ideal setup for email.  We are specifying the base email in the configMap,
# but since the configMap is shared across all checkers, we use an extra flag to add pagerDuty.  But
# that flag also needs to contain the base emails, so they have been moved here.  Going with this approach
# for now, but looking to tweak flags to watchdogs to let us move this back to the configMap (and turn on/off
# pager duty with a simple boolean.

recipient: (
        if configs.estate == "prd-sdc" then "sdn@salesforce.com"
        else if configs.estate == "prd-sam_storage" || configs.estate == "prd-sam_storagedev" then "storagefoundation@salesforce.com"
        else if configs.estate == "prd-samdev" then ""
        else if configs.estate == "prd-samtest" then ""
        else if configs.estate == "prd-samtwo" then "sam-alerts@salesforce.com"
        else if configs.kingdom == "prd" then "sam-test-alerts@salesforce.com"
        else "sam-alerts@salesforce.com"
),
laddr: (if configs.estate == "prd-sam" then "0.0.0.0:8063" else "0.0.0.0:8083"),
syntheticPort: (if configs.estate == "prd-sam" then 8063 else 8083),

pagerduty_args: (if utils.is_production(configs.kingdom) then [
        "-recipient=" + $.recipient + "," + "sam-pagerduty@salesforce.com",
] else if (configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "xrd-sam") then [
        "-recipient=" + $.recipient + "," + "sam-pagerduty@salesforce.com",
] else []),

low_urgency_pagerduty_args: (if utils.is_production(configs.kingdom) || configs.estate == "prd-samtwo" then ["-recipient=" + $.recipient + (if $.recipient != "" then "," else "") + "csc-sam-business-hours-only@salesforce.pagerduty.com"]
                             else if configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "xrd-sam" then ["-recipient=" + $.recipient + (if $.recipient != "" then "," else "") + "csc-sam-rnd-business-hours-only@salesforce.pagerduty.com"]
                             else []),

filesystem_watchdog_args: (["-recipient=" + $.recipient + (if $.recipient != "" then "," else "") + "make@salesforce.com"]),

shared_args: configs.filter_empty(
[
    "-funnelEndpoint=" + configs.funnelVIP,
    "--config=/config/watchdog.json",
    configs.sfdchosts_arg,
    "-timeout=2s",
]
),
}
