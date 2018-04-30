local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
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

    # Convert full filename "a/b/foo-bar.jsonnet" to just the filepart without ext "foo-bar"
    get_short_filename(fullFilename) :: (
        # template comes from std.thisFile which contains a path and file extension
        local emptyCheck = if std.length(fullFilename) == 0 then (error "fullFilename can not be empty");
        local splitOnSlash = std.split(fullFilename, "/");
        local lastPart = splitOnSlash[std.length(splitOnSlash)-1];
        local dotCheck = if std.length(std.split(lastPart,".")) != 2 then (error ("template filename can only contain a single period: "+lastPart) );
        std.split(lastPart, ".")[0]
    ),

    # Check for an override based on kingdom,estate,template,image.  If not found return default_tag
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # default_tag - the docker tag to use when no override is found ("sam-0000934-6f12a434")
    #
    do_override(overrides, image_name, default_tag, templateFilename):: (
        local template = self.get_short_filename(templateFilename);
        if (std.objectHas(overrides, kingdom + "," + estate + "," + template + "," + image_name)) then
            overrides[kingdom + "," + estate + "," + template + "," + image_name]
        else
            default_tag
    ),
};

# Public functions used for computing images only!
{
    # Use this for long-form images not built by TNRP
    # These can only be used in PRD
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # full_docker_image - the fully qualified docker image and tag ("ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/...")
    #
    do_override_for_not_tnrp_image(overrides, image_name, full_docker_image):: (
        internal.do_override(overrides, image_name, full_docker_image, $.templateFilename)
    ),

    # This is for TNRP tags where we need to generate the long form
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # tnrp_repo - the output repo on artifactrepo under the "tnrp" folder (usually "sam" or "sdn")
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # tag - the docker tag.  Used when no override exists, otherwise gets replaced ("sam-0000934-6f12a434")
    #
    do_override_for_tnrp_image(overrides, tnrp_repo, image_name, tag)::
        internal.add_tnrp_registry(tnrp_repo, image_name, internal.do_override(overrides, image_name, tag, $.templateFilename))
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
        local tagAfterOverride = internal.do_override(overrides, image_name, tag, $.templateFilename);
        if (std.startsWith(tagAfterOverride, "ops0-artifactrepo")) then
          tagAfterOverride
        else
          internal.add_tnrp_registry(tnrp_repo, image_name, tagAfterOverride)
      )
    ,

    # This hidden field needs to be set with the template name at time of import.  It must contain the value of std.thisFile from the template being processed
    # We use this to enable overrides per template.  It used to be set on the cmd line, but to speed up build we want to do a multi-file run of jsonnet which
    # does not allow us to pass different arguments for different templates anymore.
    #
    # This generally comes from <team>images.jsonnet, which needs to again get the value upstream from the real template.  Each template should have this:
    #
    #   local images = import "my-team-images.jsonnet" + {templateFilename :: std.thisFile}
    #
    # Then the images file passes along this value when including util_functions.
    #
    # See sam/samimages.jsonnet at the bottom for a working example
    #
    templateFilename:: error "templateFilename must be set at time of import",
}
