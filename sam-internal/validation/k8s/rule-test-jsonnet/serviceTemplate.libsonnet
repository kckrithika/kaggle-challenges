# A sample good port used for all of the tests right now, if this ever becomes reserved just change it to something else
local sampleGoodPort = 5432;

{
    override:: {
        // Expected Error defaults to pass (no error), override it if it's suppose to fail
        expectedError: "pass",
        metadata: {},
        selector: {},
        ports: [],
        spec: {},
    },

    local config = self.override,

    "$expectedError": config.expectedError,
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "foo-metadata-name",
    } + config.metadata,
    spec: {
        selector: {
            app: "foo-selector-matchLabels-name"
        } + config.selector,
        ports: [
            {
                name: "foo-port-name",
                port: sampleGoodPort,
                targetPort: sampleGoodPort,
                protocol: "TCP"
            },
        ] + config.ports,
    } + config.spec,
}