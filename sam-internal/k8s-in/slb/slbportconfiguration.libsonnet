local slbflights = import "slbflights.jsonnet";

local newPortConfiguration(
    port,
    lbType,
    targetPort = port,
    name = "",
    nodePort = 0
) = {
    port: port,
    targetport: targetPort,
    lbtype: lbType,

    // These are hidden fields (so won't show up in the stringified port config) carrying metadata used in the
    // k8s service ports definition.
    name:: name,
    nodeport:: nodePort,
};

{
    newPortConfiguration:: newPortConfiguration,

    portConfigurationToString(portConfiguration):: (
        std.manifestJsonEx(portConfiguration, " ")
    ),
}