local configs = import "config.jsonnet";
local portConfig = import "portconfig.jsonnet";

{
    common:: {
        intakeEndpoint:: "http://firefly-intake.firefly." + configs.estate + "." + configs.kingdom + ".slb.sfdc.net:" + portConfig.firefly.intake_http,
        exchangeName:: 'firefly.delivery',
        webHookSecretTokenValidationEnabled:: false,
        dockerHost:: "http://localhost:2375",
        rootDir:: "/tmp",
        dockerCertPath:: "/etc/docker/certs.d",
        artifactoryUserName:: 'svc_tnrp_artifactory',
    },
    dev:: $.common {
        artifactoryDevHost:: 'testrepo1-0-prd.data.sfdc.net',
        artifactoryP2PHost:: 'testrepo2-0-prd.data.sfdc.net',
        artifactoryContentRepoUserName:: 'svc_tnrp_ci_test',
        artifactoryContentRepoUserNameProd:: 'svc_tnrp_cd_test',
        rabbitMqUserName:: 'sfdc-rabbitmq',
    },
    prod:: $.common {
        artifactoryDevHost:: 'ops0-artifactrepo1-0-prd.data.sfdc.net',
        artifactoryP2PHost:: 'ops0-artifactrepo2-0-prd.data.sfdc.net',
        artifactoryContentRepoUserName:: 'svc_tnrp_ci',
        artifactoryContentRepoUserNameProd:: 'svc_tnrp_cd',
        rabbitMqUserName:: 'sfdc-rabbitmq',
        repositories:: 'sam/test-manifests',
    },
    prdsam:: $.dev {
        rabbitMqEndpoint:: 'firefly-rabbitmq.firefly.prd-sam.prd.slb.sfdc.net',
        rabbitMqPort:: '5672',
        repositories:: 'tnrpfirefly/test_sam_manifests,sam/test-firefly-manifests',
    },
    prdsamdev:: $.dev {
        rabbitMqEndpoint:: 'shared0-samdevkubeapi1-1-prd.eng.sfdc.net',
        rabbitMqPort:: '33672',
    },
    prdsamtest:: $.dev {
        rabbitMqEndpoint:: 'shared0-samtestkubeapi1-1-prd.eng.sfdc.net',
        rabbitMqPort:: '33672',
    },
    prdsamtwo:: $.prod {
        rabbitMqEndpoint:: 'shared0-samtwokubeapi1-1-prd.eng.sfdc.net',
        rabbitMqPort:: '33672',
    },
    environmentMapping:: {
        "prd-sam": $.prdsam,
        "prd-samdev": $.prdsamdev,
        "prd-samtest": $.prdsamtest,
        "prd-samtwo": $.prdsamtwo,
    },

}
