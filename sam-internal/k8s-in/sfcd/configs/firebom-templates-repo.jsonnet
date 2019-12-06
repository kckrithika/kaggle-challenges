local envConfig = import 'configs/firebom_service_conf.jsonnet';
local configs = import 'config.jsonnet';

{
  'repo-name': 'spinnaker',
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
        'config-json': "service_master/service_master_deployment_config.json",
        'pipeline-template': "service_master/service_master_01-01.j2",
        'pipeline-template-dev': "service_master/service_master_01-01.j2",
        'stages-json': "service_master/service_master_deployment_stages.json",
        'vars-json': "service_master/service_master_deployment_vars.json",
      },
      'env-type-aggregate': {
        'config-json': "env_type_aggregate/env_type_aggregate_deployment_config.json",
        'pipeline-template': "env_type_aggregate/env_type_aggregate_01-01.j2",
        'pipeline-template-dev': "env_type_aggregate/dev_env_type_aggregate_01-01.j2",
        'stages-json': "env_type_aggregate/env_type_aggregate_deployment_stages.json",
        'vars-json': "env_type_aggregate/env_type_aggregate_deployment_vars.json"
      },
      'fi-aggregate': {
        'config-json': "fi_aggregate/fi_aggregate_deployment_config.json",
        'pipeline-template': "fi_aggregate/fi_aggregate_01-01.j2",
        'pipeline-template-dev': "fi_aggregate/fi_aggregate_01-01.j2",
        'stages-json': "fi_aggregate/fi_aggregate_stages.json",
        'vars-json': "fi_aggregate/fi_aggregate_deployment_vars.json"
      },
      'fd-aggregate': {
        'config-json': "fd_aggregate/fd_aggregate_deployment_config.json",
        'pipeline-template': "fd_aggregate/fd_aggregate_01-01.j2",
        'pipeline-template-dev': "fd_aggregate/fd_aggregate_01-01.j2",
        'stages-json': "fd_aggregate/fd_aggregate_stages.json",
        'vars-json': "fd_aggregate/fd_aggregate_deployment_vars.json"
      },
      'cell-aggregate': {
        'config-json': "cell_aggregate/cell_aggregate_deployment_config.json",
        'pipeline-template': "cell_aggregate/cell_aggregate_01-01.j2",
        'pipeline-template-dev': "cell_aggregate/cell_aggregate_01-01.j2",
        'stages-json': "cell_aggregate/cell_aggregate_stages.json",
        'vars-json': "cell_aggregate/cell_aggregate_deployment_vars.json"
      },
      'promote-release': {
        'config-json': "promotion/promotion_config.json",
        'pipeline-template': "promotion/promotion_01-01.j2",
        'pipeline-template-dev': "promotion/promotion_01-01.j2",
        'stages-json': "promotion/promotion_stages.json",
        'vars-json': "promotion/promotion_vars.json"
      }
    }
  },
  'workspace-refresh-interval': '30s'
}
