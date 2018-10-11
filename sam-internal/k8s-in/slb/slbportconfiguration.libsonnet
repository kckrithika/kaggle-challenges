local slbflights = import "slbflights.jsonnet";

local newPortConfiguration(port, lbType, targetPort = port) = {
    port: port,
    targetport: targetPort,
    lbtype: lbType,
};

local fieldToJSON(pc, fieldName) = (
    if std.objectHas(pc, fieldName) then (
        // If the field value is a string, we need to escape it with quotes. Otherwise we print as is.
        local fieldValue = pc[fieldName];
        // We want the resulting string to look like either:
        //   ',"<fieldName>":"<fieldValue>"' (for strings), or
        //   ',"<fieldName>":<fieldValue>' (for non-strings).
        (if std.type(fieldValue) == "string" then ',"%s":"%s"' else ',"%s":%s') % [fieldName, std.toString(fieldValue)]
    )
);

local extraFieldsToJSONString(pc) = (
    // List of extra fields (fields other than port/targetport/lbtype) currently used by SLB services.
    // The order here is significant, and matches the order of current hand-crafted annotation strings.
    local fields = [
        "reencrypt",
        "sticky",
        "healthport",
        "hEaLtHpath",
        "tls",
        "healthpath",
        "healthPath"
    ];
    std.join("", std.prune([fieldToJSON(pc, field) for field in fields]))
);

local portConfigToEscapedJSONString(pc) = (
    if std.type(pc) == "string" then
        pc
    else
        "{" +
          '"port":%(port)d,"targetport":%(targetport)d,"lbtype":"%(lbtype)s"' % pc +
          extraFieldsToJSONString(pc) +
        "}"
);

local portConfigArrayToEscapedJSONString(pc) = (
    local s = [portConfigToEscapedJSONString(p) for p in pc];
    "[" + std.join(",", s) + "]"
);

{
    newPortConfiguration:: newPortConfiguration,

    portConfigurationToString(portConfiguration, readableYAML = slbflights.readablePortConfigurationAnnotations):: (
        if readableYAML then
            std.manifestJsonEx(portConfiguration, " ")
        else
            if std.type(portConfiguration) == "array" then
                portConfigArrayToEscapedJSONString(portConfiguration)
            else
                portConfigToEscapedJSONString(portConfiguration)
    ),
}