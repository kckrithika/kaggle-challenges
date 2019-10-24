local configs = import "config.jsonnet";
local portConfig = import "portconfig.jsonnet";

{
    common:: {
        firebomEndpoint:: "http://firefly-intake.firefly." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net:" + portConfig.firefly.intake_http,
        webHookSecretTokenValidationEnabled:: false,
        gitHttpLogging:: 'NONE',
    },
    prdsamtwo:: $.prod {
    },
    environmentMapping:: {
        "prd-samtwo": $.prdsamtwo,
    },

}
