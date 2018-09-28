{
  'api-url': 'https://git.soma.salesforce.com/api/v3/',
  user: 'svc-tnrp-git-rw',
  'oauth-token': '${gitRWPassword#FromSecretService}',
  'connect-timeout': '5s',
  'read-timeout': '5s',
  'write-timeout': '5s',
  'max-idle-connections': 10,
  'keep-alive-duration': '60000ms',
  url: 'https://git.soma.salesforce.com',
  'max-attempts': 3,
  'clone-timeout': '60s'
}