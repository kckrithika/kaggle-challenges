# A sample good port used for all of the tests right now, if this ever becomes reserved just change it to something else
local sampleGoodPort = 5432;

{
    override:: {
        // Expected Error defaults to pass (no error), override it if it's suppose to fail
        // Accepted error types are available in expectedErrorTypes.jsonnet
        expectedError: "pass",
        metadata: {},
        selector: {},
        templateMetadata: {},
        containers: [],
        templateSpec: {},
        template: {},
        spec: {},
    },

    local config = self.override,

    "$expectedError": config.expectedError,
    apiVersion: "extensions/v1beta1",
    kind: "DaemonSet",
    metadata: {
        name: "foo-metadata-name",
        namespace: "foo-namespace",
        labels: {
            name: "foo-label-name"
        },
    } + config.metadata,
    spec: {
        selector: {
            matchLabels: {
                name: "foo-selector-matchLabels-name"
            },
        } + config.selector,
        template: {
            metadata: {
                name: "foo-metadata-name",
                labels: {
                    name: "foo-label-name"
                },
            } + config.templateMetadata,
            spec: {
                containers: [
                    {
                        name: "foo",
                        image: "foo:1.1.4",
                        ports: [
                            {
                                containerPort: sampleGoodPort
                            },
                        ],
                    },
                ] + config.containers,
            } + config.templateSpec,
        } + config.template,
    } + config.spec,
}