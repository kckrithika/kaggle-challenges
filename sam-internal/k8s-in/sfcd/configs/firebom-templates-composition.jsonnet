{
  'working-directory': '/tmp/sfcdapifirebom',
  'default-read-id': 'test',
  'cleanup-interval': 0,
  'add-new-service-master-stages': false,
  'dev-env-type': {
    'name': 'dev',
    'default-targets': ['dev1-uswest2'],
    'default-foundation-targets': ['fdev1-uswest2'],
  },
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
        'skip-promotion-wait': false,
        'add-setup-change-case-stage': true
      },
      'prod': {
        'depends-on': ['canary'],
        'add-promotion-stage': true,
        'skip-promotion-wait': false,
        'add-close-change-case-stage': true
      }
    }
  },
  'populate-full-master-service-pipeline': true,
  'service-white-list': [
    'sfcdekstest1',
    'sfcdec2test',
    'bastion',
    'strauz',
    'strauzstage',
    'kaaskeymaker',
    'slavekdc',
    'keywatcher',
    'dns',
    'funnel',
    'funnellogs',
    'magister',
    'authsync',
    'authval',
    'praapp',
    'pradsm',
    'praui',
    'pravm',
    'preevaluated',
    'quantumk',
    'radius',
    'secds',
    'seciamsvc',
    'publicproxy',
    'cdpactvsvc',
    'cdpadminsvc',
    'cdpdata',
    'cdpgdpr',
    'mathapi',
    'math',
    'cdpmetadata',
    'cdpscheduler',
    'cdpsegment',
    'cdpinjector',
    'auth',
    'prazk',
    'fitcon',
    'fitops',
    'respublisher',
    'fitval',
    'controller',
    'vault',
    'topology',
    'cwexporter',
    'edge',
    'ajnaendpoint',
    'ajnakafka',
    'ccecom',
    'cdpairflow',
    'cdpingw',
    'jobuploader',
    'authsvc'
  ],
  'soft-launch': true
}
