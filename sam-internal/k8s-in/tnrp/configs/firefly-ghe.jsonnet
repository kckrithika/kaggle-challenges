local envConfig = import "configs/firefly_service_conf.jsonnet";
local configs = import "config.jsonnet";

{
  'api-url': 'https://git.soma.salesforce.com/api/v3/',
  user: envConfig.environmentMapping[configs.estate].gitUser,
  'oauth-token': envConfig.environmentMapping[configs.estate].gitOauthToken,
  'connect-timeout': '5s',
  'read-timeout': '5s',
  'write-timeout': '5s',
  'max-idle-connections': 10,
  'keep-alive-duration': '60000ms',
  url: 'https://git.soma.salesforce.com',
  'max-attempts': 3,
  'clone-timeout': '60s',
  'dark-launch': '${DARKLAUNCH}',
}
