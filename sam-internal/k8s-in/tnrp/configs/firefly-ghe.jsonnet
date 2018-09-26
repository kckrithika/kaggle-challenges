{
  'api-url': 'https://git.soma.salesforce.com/api/v3/',
  user: 'svc-tnrp-git-rw',
  'oauth-token': '${gitRWPassword#FromSecretService}',
  'connect-timeout': '60000ms',
  'read-timeout': '60000ms',
  'write-timeout': '60000ms',
  'max-idle-connections': 10,
  'keep-alive-duration': '60000ms',
  url: 'https://git.soma.salesforce.com',
}