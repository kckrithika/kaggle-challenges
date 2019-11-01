local configs = import "config.jsonnet";
local portConfig = import "portconfig.jsonnet";

{
    common:: {
        webHookSecretTokenValidationEnabled:: false,
        gitHttpLogging:: 'NONE',
    },
    prod:: $.common {
        gitUser: 'tok-cdapigitrw',
        gitOauthToken: '${ghe_rw_token#FromSecretService}',
    },
    prdsamtwo:: $.prod {
    },
    environmentMapping:: {
        "prd-samtwo": $.prdsamtwo,
    },

}
