local sampleGoodPort = 5432;

{
    override:: {
        expectedError: "pass",
        system: {},
        functions: {},
        containers: {},
        livenessProbe: {},
        loadbalancers: {},
        lbports: {},
    },

    local config = self.override,

    "$expectedError": config.expectedError,
    apiVersion: "v1",
    system: {
        functions: [
            {
                name: "foo-function",
                count: 1,
                containers: [
                    {
                        name: "foo-container",
                        image: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/foo/bar:1.1-sfdc",
                        port: [
                            {
                                containerPort: sampleGoodPort
                            },
                        ],

                        livenessProbe: {
                            httpGet: {
                                port: sampleGoodPort
                            },
                        } + config.livenessProbe,

                        volumeMounts: [
                            {
                                name: "foo-volume-mounts",
                                mountPath: "/foo-mount-path/"
                            },
                        ],

                        env: [
                            {
                                name: "FOO_ENV_NAME",
                                value: "bar"
                            },
                        ],
                    } + config.containers,
                ],

            } + config.functions,
        ],

        loadbalancers: [
            {
                lbname: "foo-lb",
                "function": "foo-function",
                ports: [
                    {
                        port: sampleGoodPort,
                        targetport: sampleGoodPort
                    } + config.lbports,
                ],
            } + config.loadbalancers,
        ],
    } + config.system
}
