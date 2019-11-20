{
  'working-directory': '/tmp/sfcdapifirebom',
  'default-read-id': 'test',
  'cleanup-interval': 0,
  'dev-env-type': 'dev',
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
  'populate-full-master-service-pipeline': true,
  'service-white-list': [ 'sfcdekstest1', 'strauz', 'sfcdec2test' ],
  'soft-launch': true,
  'vmf-parser-configs': {
    'k8s-account': 'aws-dev1-uswest2-sfcdtest-sfcdekstest1-platformcluster',
    'namespace': 'apoorv-test', # To be changed once the official namespace is available
    'image': '791719295754.dkr.ecr.us-east-2.amazonaws.com/dva/sfcd-vmf-parser:latest',
    'active-deadline-seconds': 60,
    'ttl-seconds-after-finished': 300,
  }
}
