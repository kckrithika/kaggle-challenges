local envConfig = import "configs/firefly_service_conf.jsonnet";
local configs = import "config.jsonnet";

{
  base:: {
    'artifactory-dev-host': envConfig.environmentMapping[configs.estate].artifactoryDevHost,
    'artifactory-p2p-host': envConfig.environmentMapping[configs.estate].artifactoryP2PHost,
    'artifactory-user-name': envConfig.environmentMapping[configs.estate].artifactoryUserName,
    'artifactory-password': '${artifactoryPassword#FromSecretService}',
    'artifact-manifest-time-property-key':'snd_artifact_promotion_time',
    'artifactory-content-repo-rc': 'content_repo_rc',
    'artifactory-content-repo-prod': 'content_repo_prod',
    'artifactory-content-repo-gcp': 'content_repo_gcp',
    'artifactory-remote-content-repo': 'content_repo',
    'artifactory-dev-api-endpoint': 'https://${appconfig.artifactory.artifactory-dev-host}/artifactory/',
  },

  prod:: self.base + {
    'artifactory-dev-endpoint': 'https://${appconfig.artifactory.artifactory-dev-host}/',
    'artifactory-p2p-endpoint': 'https://${appconfig.artifactory.artifactory-p2p-host}/',
    'artifactory-p2p-api-endpoint': 'https://${appconfig.artifactory.artifactory-p2p-host}/artifactory/',
    'artifactory-content-repo-user-name': envConfig.environmentMapping[configs.estate].artifactoryContentRepoUserName,
    'artifactory-content-repo-password': '${artifactoryContentRepoPassword#FromSecretService}',
    'socket-timeout': '30000ms',
    'connection-timeout': '20000ms',
    'max-retry': 3,
    'backoff-time': '1000ms',
    'artifactory-content-repo-user-name-prod': envConfig.environmentMapping[configs.estate].artifactoryContentRepoUserNameProd,
    'artifactory-content-repo-password-prod': '${artifactoryContentRepoPasswordProd#FromSecretService}',
  },
}
