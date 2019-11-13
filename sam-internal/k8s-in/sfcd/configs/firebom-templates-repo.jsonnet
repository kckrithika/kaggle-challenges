local envConfig = import 'configs/firebom_service_conf.jsonnet';
local configs = import 'config.jsonnet';

{
  'repo-name': 'spinnaker',
  'repo-org': 'sfcd',
  'enable-push-to-origin': true,
  'enable-pr-creation': true,
  'enable-approve-pr': true,
  'enable-self-approve-pr': true,
  'dev-env-configs': {
    'expected-artifacts-vars-json': "templatesrepo/expected_artifacts/vars/dev_expected_artifacts.json",
    'triggers-vars-json': "templatesrepo/triggers/vars/dev_triggers.json",
  },
  'dev-env-type': "dev",
  'composed-templates': {
    'location': 'lib/templates',
    'master-pipelines-dir': 'pipelines/masterpipeline',
    'master-deployment-pipeline-templates': {
      'service-master': {
        'pipeline-template': 'service_master_01-00.j2',
        'vars-json': 'templatesrepo/master_service_deployment_vars.json',
        'config-json': 'templatesrepo/master_deployment_config.json',
        'stages-json': 'templatesrepo/master_deployment_stages.json',
      },
      'env-type-aggregate': {
        'pipeline-template': 'env_type_master_01-00.j2',
        'vars-json': 'templatesrepo/master_deployment_vars.json',
        'config-json': 'templatesrepo/master_deployment_config.json',
        'stages-json': 'templatesrepo/master_deployment_stages.json',
      },
      'fi-aggregate': {
        'pipeline-template': 'fi_master_01-00.j2',
        'vars-json': 'templatesrepo/master_deployment_vars.json',
        'config-json': 'templatesrepo/master_deployment_config.json',
        'stages-json': 'templatesrepo/master_deployment_stages.json',
      },
      'fd-aggregate': {
        'pipeline-template': 'fd_master_01-00.j2',
        'vars-json': 'templatesrepo/master_deployment_vars.json',
        'config-json': 'templatesrepo/master_deployment_config.json',
        'stages-json': 'templatesrepo/master_deployment_stages.json',
      },
      'cell-aggregate': {
        'pipeline-template': 'cell_master_01-00.j2',
        'vars-json': 'templatesrepo/master_deployment_vars.json',
        'config-json': 'templatesrepo/master_deployment_config.json',
        'stages-json': 'templatesrepo/master_deployment_stages.json',
      },
      'promote-release': {
        'pipeline-template': 'promotion_01-00.j2',
        'vars-json' : 'templatesrepo/promote_release_vars.json',
        'config-json': 'templatesrepo/master_deployment_config.json',
        'stages-json': 'templatesrepo/master_deployment_stages.json'
      }
    }
  }
}

