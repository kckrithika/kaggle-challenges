local flowsnake_images = import "flowsnake_images.jsonnet";
local watchdog = import "watchdog.jsonnet";
# This is a copy and re-config of watchdog.jsonnet
{
    watchdog_config: watchdog.watchdog_config {
        "email-subject-prefix": "HBASEWD",
        "deployer-recipient": "bigdataatscale@salesforce.com",
        "deployer-sender": "bigdataatscale@salesforce.com",
        recipient: (if "hbase_wd_no_email" in flowsnake_images.feature_flags then "" else "bigdataatscale@salesforce.com"),
        sender: "bigdataatscale@salesforce.com",
    }
}
