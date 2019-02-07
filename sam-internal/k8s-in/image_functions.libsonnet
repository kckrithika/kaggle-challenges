local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local configs = import "config.jsonnet";

# Private functions
local internal = {
    # Given an image tag, deduce the pipeline (dva strata, tnrp, etc) that produced this image and extract
    # build information from the tag.
    # tnrp: Tags for images produced from the TnRP docker pipeline are expected to have the form:
    #           <prefix>-<zero-padded build number>-<short git commit sha>
    #       e.g.,:
    #           sam-0002472-fe691728
    #           v-0001445-667a3b24
    # dva: Tags for images produced from the dva strata docker pipeline are expected to have the form:
    #           <build number>-<git commit sha>
    #       e.g.,:
    #           2040-c5e2a439bdf21e01468c293c07012926b1fd7621
    #           62-877b876aa278951ef92bc236837c985bfb77091e
    get_build_info_from_image_tag(tag):: (
        local tag_parts = std.split(tag, "-");
        if (std.length(tag_parts) == 3 && std.length(tag_parts[1]) == 7 && std.length(tag_parts[2]) == 8) then
        {
            pipeline: "tnrp",
            rcRegistry: "docker-release-candidate",
            registryPath: "tnrp",
            buildNumber: std.parseInt(tag_parts[1]),
            commitSHA: tag_parts[2],
        }
        else if (std.length(tag_parts) == 3 && std.length(tag_parts[1]) == 8 && std.length(tag_parts[2]) == 3) then
        {
            # The ancient form of tnrp image tags used a format like:
            #    <prefix>-<short git commit sha>-<build number>
            # The only container using this form of image tag is the permissionInitContainer:
            # https://git.soma.salesforce.com/sam/manifests/blob/53356a137beb72ce5352d909b76c6014c31a5d1e/sam-internal/k8s-in/sam/samimages.jsonnet#L62-L67
            pipeline: "tnrp",
            rcRegistry: "docker-release-candidate",
            registryPath: "tnrp",
            buildNumber: std.parseInt(tag_parts[2]),
            commitSHA: tag_parts[1],
        }
        else if (std.length(tag_parts) == 2 && std.length(tag_parts[1]) == 40) then
        {
            pipeline: "strata",
            rcRegistry: "docker-dva-rc",
            registryPath: "dva",
            buildNumber: std.parseInt(tag_parts[0]),
            commitSHA: tag_parts[1],
        }
        else
            std.assertEqual(tag, "Unknown image tag format")
    ),

    # Add the hostname if deploying an image built by a known pipeline.
    # When a pipeline builds images, they first show up on artifactrepo under the release candidate
    # registry ("docker-release-candidate" for tnrp, "docker-dva-rc" for strata).
    # When they get promoted to production, they show up under "docker-all", but we have chosen
    # to leave off the root folder for prod which means "search all registries".
    # TODO: We should consider switching to a explicit root folder for prod.
    #
    # repo - the output repo on artifactrepo under the "tnrp" folder (usually "sam" or "sdn")
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # tag - the docker tag.  Used when no override exists, otherwise gets replaced ("sam-0000934-6f12a434")
    #
    add_registry(repo, image_name, tag):: (
        local buildInfo = $.get_build_info_from_image_tag(tag);
        if (kingdom == "prd") then
            std.join("/", [configs.registry, buildInfo.rcRegistry, buildInfo.registryPath, repo, image_name]) + ":" + tag
        else
            std.join("/", [configs.registry, buildInfo.registryPath, repo, image_name]) + ":" + tag
        ),

    # Convert full filename "a/b/foo-bar.jsonnet" to just the filepart without ext "foo-bar"
    get_short_filename(fullFilename):: (
        # template comes from std.thisFile which contains a path and file extension
        local emptyCheck = if std.length(fullFilename) == 0 then (error "fullFilename can not be empty");
        local splitOnSlash = std.split(fullFilename, "/");
        local lastPart = splitOnSlash[std.length(splitOnSlash) - 1];
        local dotCheck = if std.length(std.split(lastPart, ".")) != 2 then (error ("template filename can only contain a single period: " + lastPart));
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
        local overrideKeys = [
            std.join(",", [kingdom, estate, template, image_name]),
            std.join(",", [kingdom, estate, "*", image_name]),
        ];
        local overrideTags = [overrides[overrideKey] for overrideKey in overrideKeys if std.objectHas(overrides, overrideKey)];
        if std.length(overrideTags) > 0 then
            overrideTags[0]
        else
            default_tag
    ),
};

# Public functions used for computing images only!
{
    # Use this for long-form images not built by a known pipeline (tnrp or dva strata).
    # These can only be used in PRD
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # full_docker_image - the fully qualified docker image and tag ("ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/...")
    #
    do_override_for_non_pipeline_image(overrides, image_name, full_docker_image):: (
        internal.do_override(overrides, image_name, full_docker_image, $.templateFilename)
    ),

    # This is for tags from images for known pipelines (tnrp or dva strata) where we need to generate the long form.
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # repo - the output repo (usually "sam" or "sdn") on artifactrepo under the build pipeline folder ("tnrp", "dva").
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # tag - the docker tag.  Used when no override exists, otherwise gets replaced ("sam-0000934-6f12a434")
    #
    do_override_for_pipeline_image(overrides, repo, image_name, tag)::
        internal.add_registry(repo, image_name, internal.do_override(overrides, image_name, tag, $.templateFilename))
    ,

    # This is for tags where it may have the full repository path. If it does
    # then do not add anything, otherwise add the correct pipeline registry.
    #
    # overrides - a map of "kingdom,estate,template,image" to "tag"
    # repo - the output repo (usually "sam" or "sdn") on artifactrepo under the build pipeline folder ("tnrp", "dva").
    # image_name - the docker image name (usually "hypersam" or "hypersdn")
    # tag - the docker tag.  Used when no override exists, otherwise gets replaced ("sam-0000934-6f12a434")
    #
    do_override_based_on_tag(overrides, repo, image_name, tag):: (
        local tagAfterOverride = internal.do_override(overrides, image_name, tag, $.templateFilename);
        if (std.startsWith(tagAfterOverride, "ops0-artifactrepo") || std.startsWith(tagAfterOverride, "ops-artifactrepo") || std.startsWith(tagAfterOverride, "gcr.io")) then
          tagAfterOverride
        else
          internal.add_registry(repo, image_name, tagAfterOverride)
      )
    ,

    build_info_from_tag(tag):: (
        internal.get_build_info_from_image_tag(tag)
    ),

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
