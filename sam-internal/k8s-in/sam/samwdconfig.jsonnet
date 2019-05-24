{
local estate = std.extVar("estate"),
local kingdom = std.extVar("kingdom"),
local configs = import "config.jsonnet",
local utils = import "util_functions.jsonnet",

# We used to send emails for all watchdogs, but over time we switched to just pagerduty
# We can check with sdc to see if they are ok dropping the last entry as well
recipient: (
        if configs.estate == "prd-sdc" then "sdn@salesforce.com"
        else ""
),
# TODO: Any watchdog with an empty sender will not send email.  This is a mistake, but
# we are under moratorium and we can not change production right now.  FIX THIS ASAP!!!
sender: (
        if utils.is_production(configs.kingdom) then ""
        else "sam-alerts@salesforce.com"
),

laddr: (if configs.estate == "prd-sam" then "0.0.0.0:8063" else "0.0.0.0:8083"),
syntheticPort: (if configs.estate == "prd-sam" then 8063 else 8083),

# TODO: Remove $.recipient once we are done with moratorium
pagerduty_args: (if utils.is_production(configs.kingdom) || configs.estate == "prd-sam" || configs.estate == "prd-samtwo" || configs.estate == "xrd-sam" then [
        "-recipient=" + $.recipient + "," + "sam-pagerduty@salesforce.com",
] else []),

# TODO: Remove $.recipient once we are done with moratorium
low_urgency_pagerduty_args: (if utils.is_production(configs.kingdom) || configs.estate == "prd-samtwo" then [
        "-recipient=" + $.recipient + (if $.recipient != "" then "," else "") + "csc-sam-business-hours-only@salesforce.pagerduty.com",
] else if configs.estate == "prd-sam" || configs.estate == "prd-samtest" || configs.estate == "prd-samdev" || configs.estate == "xrd-sam" then [
        "-recipient=" + $.recipient + (if $.recipient != "" then "," else "") + "csc-sam-rnd-business-hours-only@salesforce.pagerduty.com",
] else []),

filesystem_watchdog_args: (
[
        "-recipient=" + $.recipient + (if $.recipient != "" then "," else "") + "make@salesforce.com",
]
),

shared_args: configs.filter_empty(
[
    "-funnelEndpoint=" + configs.funnelVIP,
    "--config=/config/watchdog.json",
    configs.sfdchosts_arg,
    "-timeout=2s",
]
),
}
