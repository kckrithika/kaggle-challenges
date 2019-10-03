local watchdog = import "watchdog.jsonnet";
# This is a copy and re-config of watchdog.jsonnet
{
    watchdog_config: watchdog.watchdog_config {
        "email-subject-prefix": "HBASEWD",
        "deployer-recipient": "bigdataatscale@salesforce.com",
        "deployer-sender": "bigdataatscale@salesforce.com",
        recipient: "bigdataatscale@salesforce.com",
        sender: "bigdataatscale@salesforce.com",
    }
}
