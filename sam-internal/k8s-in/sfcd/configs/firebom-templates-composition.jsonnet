{
  'working-directory': '/tmp/sfcdapifirebom',
  'default-read-id': 'test',
  'cleanup-interval': 0,
  'add-new-service-master-stages': false,
  'dev-env-type-name': 'dev',
  'env-type-configs': {
    'default': [
      {
        'name': 'dev',
        'add-promotion-stage': false,
        'default-targets': [
          'dev1-uswest2'
        ],
        'default-foundation-targets': [
          'fdev1-uswest2'
        ]
      },
      {
        'name': 'test',
        'depends-on': [
          'dev'
        ],
        'add-promotion-stage': true,
        'skip-promotion-wait': true
      },
      {
        'name': 'canary',
        'add-setup-change-case-stage': true,
        'add-promotion-stage': true,
        'depends-on': [
          'test'
        ],
        'skip-promotion-wait': false
      },
      {
        'name': 'prod',
        'add-close-change-case-stage': true,
        'add-promotion-stage': true,
        'depends-on': [
          'canary'
        ],
        'skip-promotion-wait': false,
        'aliases': [
          'esvc'
        ]
      }
    ]
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
    'cdpingw',
    'jobuploader',
    'authsvc',
    'caaspc',
    'coreapp',
    'flowsnakeip',
    'flowsnake',
    'flowsnakeso'
  ],
  'soft-launch': true
}
