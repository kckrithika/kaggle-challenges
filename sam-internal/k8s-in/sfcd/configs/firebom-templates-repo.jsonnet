local envConfig = import "configs/firebom_service_conf.jsonnet";
local configs = import "config.jsonnet";

{
  'repo-name': 'test-spinnaker-templates',
  'repo-org': 'sfcd',
  'composed-templates': {
    'location': "lib/templates",
    'master-pipelines-dir': "pipelines/masterpipeline",
    'master-deployment-pipeline-templates': {
      'service_master': "service_master_01-00.j2",
      'env_type_master': "env_type_master_01-00.j2",
      'fi_master': "fi_master_01-00.j2",
      'fd_master': "fd_master_01-00.j2",
      'cell_master': "cell_master_01-00.j2",
      }
  }
}

