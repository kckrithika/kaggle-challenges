local envConfig = import 'configs/firebom_service_conf.jsonnet';
local configs = import 'config.jsonnet';

{
    'repo-name': 'e2etest-spinnaker-templates',
    'repo-org': 'sfcd',
    'enable-push-to-origin': true,
    'enable-pr-creation': true,
    'enable-approve-pr': true,
    'enable-self-approve-pr': true,
    'composed-templates': {
      'location': 'lib/templates',
      'master-pipelines-dir': 'pipelines/masterpipeline',
      'master-deployment-pipeline-templates': {
        'service-master': {
          'pipeline-template': 'service_master_01-00.j2',
          'vars-json': 'templatesrepo/master_service_deployment_vars.json',
          'config-json': 'templatesrepo/master_config.json',
          'stages-json': 'templatesrepo/master_deployment_stages.json',
        },
        'env-type-aggregate': {
          'pipeline-template': 'env_type_master_01-00.j2',
          'vars-json': 'templatesrepo/master_env_type_deployment_vars.json',
          'config-json': 'templatesrepo/master_config.json',
          'stages-json': 'templatesrepo/master_deployment_stages.json',
        },
        'fi-aggregate': {
          'pipeline-template': 'fi_master_01-00.j2',
          'vars-json': 'templatesrepo/master_deployment_vars.json',
          'config-json': 'templatesrepo/master_config.json',
          'stages-json': 'templatesrepo/master_deployment_stages.json',
        },
        'fd-aggregate': {
          'pipeline-template': 'fd_master_01-00.j2',
          'vars-json': 'templatesrepo/master_deployment_vars.json',
          'config-json': 'templatesrepo/master_config.json',
          'stages-json': 'templatesrepo/master_deployment_stages.json',
        },
        'cell-aggregate': {
          'pipeline-template': 'cell_master_01-00.j2',
          'vars-json': 'templatesrepo/master_deployment_vars.json',
          'config-json': 'templatesrepo/master_config.json',
          'stages-json': 'templatesrepo/master_deployment_stages.json',
        }
      }
    }
}

