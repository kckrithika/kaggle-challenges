{
  'working-directory': '/tmp/sfcdapifirebom',
  'default-read-id': 'test',
  'cleanup-interval': 0,
  'env-type-hierarchies': {
    'default': {
      'dev': {
        'add-promotion-stage': false
      },
      'test': {
        'depends-on': ['dev'],
        'add-promotion-stage': true,
        'skip-promotion-wait': true
      },
      'canary': {
        'depends-on': ['test'],
        'add-promotion-stage': true,
        'skip-promotion-wait': false
      },
      'prod': {
        'depends-on': ['canary'],
        'add-promotion-stage': true,
        'skip-promotion-wait': false
      }
    }
  },
  'vmf-parser-configs': {
    'k8s-account': 'k8s-spinnaker1-v2-account',
    'namespace': 'apoorv-test', # To be changed once the official namespace is available
    'image': 'gcr.io/gsf-mgmt-devmvp-spinnaker/dva/sfcd-vmf-parser:latest'
  }
}
