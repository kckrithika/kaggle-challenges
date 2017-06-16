local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local template = std.extVar("template");
local configs = import "config.jsonnet";

# Private functions
local internal = {
    # Add the hostname if deploying an image built by TNRP
    # When TNRP builds images, they first show up on artifactrepo under "docker-release-candidate"
    # When they get promoted to production, they show up under "docker-all", but we have chosen
    # to leave off the root folder for prod which means "search all registries".
    # TODO: We should consider switching to a explicit root folder for prod.
    add_tnrp_registry(repo, image_name, tag):: (
        if (kingdom == "prd") then
            configs.registry + "/" + "docker-release-candidate/tnrp/"+repo+"/" + image_name + ":" + tag
        else
            configs.registry + "/" + "tnrp/"+repo+"/" + image_name + ":" + tag
        ),

    do_override(overrides, image_name, default_tag):: (
        if ( std.objectHas(overrides, kingdom+","+estate+","+template+","+image_name) ) then
            overrides[kingdom+","+estate+","+template+","+image_name]
        else
            default_tag
    ),
};

# Public functions
{
    # Use this for long-form images not built by TNRP
    # These can only be used in PRD
    do_override_for_not_tnrp_image(overrides, image_name, default_tag):: (
        internal.do_override(overrides, image_name, default_tag)
    ),

    # This is for TNRP tags where we need to generate the long form
    do_override_for_tnrp_image(overrides, repo, image_name, tag):: 
        internal.add_tnrp_registry(repo, image_name, internal.do_override(overrides, image_name, tag))
    ,
}