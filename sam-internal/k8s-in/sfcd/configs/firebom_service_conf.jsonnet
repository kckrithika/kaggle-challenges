local configs = import "config.jsonnet";
local portConfig = import "portconfig.jsonnet";

{
    common:: {
        firebomEndpoint:: "http://firefly-intake.firefly." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net:" + portConfig.sfcd.firebom_http,
        webHookSecretTokenValidationEnabled:: false,
        gitHttpLogging:: 'NONE',
    },
    prod:: $.common {
        gitUser: 'svc-tnrp-git-rw',
        gitOauthToken: '${gitRWPassword#FromSecretService}',
    },
    prdsamtwo:: $.prod {
    },
    environmentMapping:: {
        "prd-samtwo": $.prdsamtwo,
    },

}
