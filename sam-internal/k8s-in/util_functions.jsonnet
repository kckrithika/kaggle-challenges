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
    #
    # tnrp_repo - the output repo on artifactrepo under the "tnrp" folder (usually "sam" or "sdn")
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # tag - the docker tag.  Used when no override exists, otherwise gets replaced ("sam-0000934-6f12a434")
    #
    add_tnrp_registry(tnrp_repo, image_name, tag):: (
        if (kingdom == "prd") then
            configs.registry + "/" + "docker-release-candidate/tnrp/" + tnrp_repo + "/" + image_name + ":" + tag
        else
            configs.registry + "/" + "tnrp/" + tnrp_repo + "/" + image_name + ":" + tag
        ),

    # Check for an override based on kingdom,estate,template,image.  If not found return default_tag
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # default_tag - the docker tag to use when no override is found ("sam-0000934-6f12a434")
    #
    do_override(overrides, image_name, default_tag):: (
        if (std.objectHas(overrides, kingdom + "," + estate + "," + template + "," + image_name)) then
            overrides[kingdom + "," + estate + "," + template + "," + image_name]
        else
            default_tag
    ),
};

# Public functions
{
    # Use this for long-form images not built by TNRP
    # These can only be used in PRD
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # full_docker_image - the fully qualified docker image and tag ("ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/...")
    #
    do_override_for_not_tnrp_image(overrides, image_name, full_docker_image):: (
        internal.do_override(overrides, image_name, full_docker_image)
    ),

    # This is for TNRP tags where we need to generate the long form
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # tnrp_repo - the output repo on artifactrepo under the "tnrp" folder (usually "sam" or "sdn")
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # tag - the docker tag.  Used when no override exists, otherwise gets replaced ("sam-0000934-6f12a434")
    #
    do_override_for_tnrp_image(overrides, tnrp_repo, image_name, tag)::
        internal.add_tnrp_registry(tnrp_repo, image_name, internal.do_override(overrides, image_name, tag))
    ,

    # This is for tags where it may have the full repository path. If it does
    # then do not add anything, otherwise add the tnrp registry
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # tnrp_repo - the output repo on artifactrepo under the "tnrp" folder (usually "sam" or "sdn")
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # tag - the docker tag.  Used when no override exists, otherwise gets replaced ("sam-0000934-6f12a434")
    #
    do_override_based_on_tag(overrides, tnrp_repo, image_name, tag):: (
        local tagAfterOverride = internal.do_override(overrides, image_name, tag);
        if (std.startsWith(tagAfterOverride, "ops0-artifactrepo")) then
          tagAfterOverride
        else
          internal.add_tnrp_registry(tnrp_repo, image_name, tagAfterOverride)
      )
    ,

    # This is for filtering Public Clouds from Private Clouds
    is_public_cloud(kingdom):: (
        kingdom == "cdu" || kingdom == "syd" || kingdom == "yhu" || kingdom == "yul"
    ),

    # This is for filtering GIA
    is_gia(kingdom):: (
        kingdom == "chx" || kingdom == "wax"
    ),

    # This is for filtering in, or out, testing clusters.
    is_test_cluster(estate):: (
        estate == "prd-samdev" || estate == "prd-samtest" || estate == "prd-sdc" || estate == "prd-sam"
    ),

    # This is for filtering flowsnake clusters.
    is_flowsnake_cluster(estate):: (
        estate == "prd-data-flowsnake" || estate == "prd-data-flowsnake_test" || estate == "prd-dev-flowsnake_iot_test"
    ),
}
