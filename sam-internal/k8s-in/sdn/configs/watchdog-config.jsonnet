local configs = import "config.jsonnet";
local sdnimages = import "sdnimages.jsonnet";

{
  # Snoozes - This is a central list of all snoozed watchdogs.  For each snooze, please add a comment explaining the reason
  # Format of struct is here: https://git.soma.salesforce.com/sam/sam/blob/master/pkg/tools/watchdog/internal/config/config.go
  # Fields `estates`, `checker`, and `until` are required.  Specific instances can be listed with `instances` or using regex with `instanceRegex`
  # Until date format is YYYY/MM/DD.
  #
  # Example: { estates: ["prd-sdc"], checker: "PingValidator", until: "2017/06/02" },
  snooze: [
  ],

  # Shared
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  tlsEnabled: true,
  funnelEndpoint: configs.funnelVIP,
  rcImtEndpoint: configs.rcImtEndpoint,
  smtpServer: configs.smtpServer,
  sender: "sdn-alerts@salesforce.com",
  recipient: (
	if configs.kingdom == "prd" then "sdn@salesforce.com"
	else "sdn-alerts@salesforce.com"),
  imageName: sdnimages.hypersdn,
}
