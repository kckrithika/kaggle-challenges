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
    'radius',
    'cdpactvsvc',
    'cdpadminsvc',
    'cdpdata',
    'cdpgdpr',
    'mathapi',
    'math',
    'cdpmetadata',
    'cdpscheduler',
    'cdpsegment',
    'cdpinjector'
  ],
  'soft-launch': true
}
