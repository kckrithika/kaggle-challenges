local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local template = std.extVar("template");
local configs = import "config.jsonnet";
{
    # Check if there is a global override
    
    dooverrides(overrides, image_name, default_tag):: (
        if ( std.objectHas(overrides, kingdom+","+estate+","+template+","+image_name) ) then
            overrides[kingdom+","+estate+","+template+","+image_name]
        else
            default_tag
    ),

    # Add the hostname if deploying an image built by TNRP
    
    addtnrpregistry(repo, imagename, tag):: (
        if (kingdom == "prd") then
            configs.registry + "/" + "docker-release-candidate/tnrp/"+repo+"/" + imagename + ":" + tag
        else
            configs.registry + "/" + "tnrp/"+repo+"/" + imagename + ":" + tag
        ),
}