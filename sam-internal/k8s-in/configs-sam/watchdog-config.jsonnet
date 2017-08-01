local configs = import "config.jsonnet";
local samimages = import "samimages.jsonnet";

{
  caFile: configs.caFile,
  keyFile: configs.keyFile,
  certFile: configs.certFile,
  tlsEnabled: true,
  funnelEndpoint: configs.funnelVIP,
  rcImtEndpoint: configs.rcImtEndpoint,
  smtpServer: configs.smtpServer,
  sender: configs.watchdog_emailsender,
  recipient: configs.watchdog_emailrec,

  # Hairpin Deployer
  # TODO: Jsonnet does not allow dashes in field names.
  # Also, we can just use the base flags instead of making a copy just for deployer
  #deployer-imageName: samimages.hypersam,
  #deployer-funnelEndpoint: configs.funnelVIP,
  #deployer-rcImtEndpoint: configs.rcImtEndpoint,
  #deployer-smtpServer: configs.smtpServer,
  #deployer-sender: configs.watchdog_emailsender,
  #deployer-recipient: configs.watchdog_emailrec,

  k8sproxyEndpoint: "http://localhost:40000",

  # Puppet
  maxUptimeSampleSize: 5,
  # Pod
  podNamespacePrefixBlacklist: "sam-watchdog",  
  # Sdp
  sdpEndpoint: "http://localhost:39999",
  # Synthetic
  laddr: "0.0.0.0:8083",
  imageName: samimages.hypersam,
} + 
(
  if configs.kingdom == "prd" then {
    deploymentNamespacePrefixWhitelist: "sam-system,csc-sam" 
  } else {}
)
