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
        gitHttpLogging:: 'NONE',
        prrRoutingKeyFormat:: '%s-%s.pr',
        pushRoutingKeyFormat:: '%s-%s.package',
    },
    dev:: $.common {
        artifactoryDevHost:: 'testrepo1-0-prd.data.sfdc.net',
        artifactoryP2PHost:: 'testrepo2-0-prd.data.sfdc.net',
        artifactoryContentRepoUserName:: 'svc_tnrp_ci_test',
        artifactoryContentRepoUserNameProd:: 'svc_tnrp_cd_test',
        gitUser: 'tok-firefly-git-test',
        gitOauthToken: '${gitFireflyTestOauthToken#FromSecretService}',
    },
    prod:: $.common {
        artifactoryDevHost:: 'ops0-artifactrepo1-0-prd.data.sfdc.net',
        artifactoryP2PHost:: 'ops0-artifactrepo2-0-prd.data.sfdc.net',
        artifactoryContentRepoUserName:: 'svc_tnrp_ci',
        artifactoryContentRepoUserNameProd:: 'svc_tnrp_cd',
        rabbitMqUserName:: 'rabbitmq-admin',
        rabbitMqPassword:: '${rabbitMqAdmin#FromSecretService}',
        repositories:: 'sam/test-manifests',
        gitUser: 'svc-tnrp-git-rw',
        gitOauthToken: '${gitRWPassword#FromSecretService}',
    },
    prdsam:: $.dev {
        gitHttpLogging:: 'NONE',
        rabbitMqUserName:: 'rabbitmq-admin',
        rabbitMqPassword:: '${rabbitMqAdmin#FromSecretService}',
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
        rabbitMqEndpoint:: 'firefly-rabbitmq.firefly.prd-samtwo.prd.slb.sfdc.net',
        rabbitMqPort:: '5672',
        repositories:: 'sam/test-manifests,sam/manifests',
    },
    environmentMapping:: {
        "prd-sam": $.prdsam,
        "prd-samdev": $.prdsamdev,
        "prd-samtest": $.prdsamtest,
        "prd-samtwo": $.prdsamtwo,
    },

}
