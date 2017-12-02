local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
{
    sdn_watchdog_emailsender: "sdn-alerts@salesforce.com",
    sdn_watchdog_emailrec: (if kingdom == "chx" || kingdom == "wax" || estate == "prd-samdev" || estate == "prd-samtest" || estate == "prd-sam_storage" || estate == "prd-sdc" || estate == "prd-data-flowsnake_test" then "sdn@salesforce.com" else "sdn-alerts@salesforce.com"),
}
