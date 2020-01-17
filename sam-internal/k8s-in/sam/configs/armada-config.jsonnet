local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

{
  armadaTemplatesGitOrgName: "armada",
  armadaTemplatesGitRepoName: "armada-templates",
  armadaTemplatesBranchName: "master",
  armadaRepoProvisioningTemplateFilePath: "repo-provision",
  armadaCITemplateFilePath: "scone-app/ci/.strata.yml",
  gusPollInterval: 10,
  "secrets:certfile": configs.certFile,
  "secrets.keyfile": configs.keyFile,
  "secrets.cafile": configs.caFile,
  "secrets.ssendpoint": "secretservice.dmz.salesforce.com",
}
