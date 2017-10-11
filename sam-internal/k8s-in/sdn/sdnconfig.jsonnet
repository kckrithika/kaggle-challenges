local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    sdn_watchdog_emailsender: "sdn-alerts@salesforce.com",
    sdn_watchdog_emailrec: (if estate == "prd-samdev" || estate == "prd-samtest" || estate == "prd-sam_storage" || estate == "prd-sdc" then "sdn@salesforce.com" else "sdn-alerts@salesforce.com"),
}
