local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

{
  ### Global overrides - Anything here will override anything below
  overrides: {
    #
    # This section lets you override any istio pilot image for a given kingdom,estate,template,image.
    # Template is the short name of the template.
    # For k8s-in/templates/istio-pilot-deployment.jsonnet use "istio-pilot-deployment"
    #
    # Example:
    #   # [alias] Added this override to fix issue xxx
    #   "prd,prd-sam,*,pilot": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/shaktiprakash-das/istio/pilot:1.0.2",
    #   "prd,prd-samtest,istio-pilot-deployment,pilot": "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/shaktiprakash-das/istio/pilot:1.0.2",

  },

  ### Per-phase image tags
  per_phase: {
    ### Release Phase 0 - Nightly deployment of the most recent hypersam to prd-samtest
    # Under normal cirumstances we should not need to change this section.
    # Overrides work just fine in this phase.  To see the active istio pilot tag visit:
    # https://git.soma.salesforce.com/sam/sam/wiki/SAM-Auto-Deployer#how-to-find-phase-0-hypersam-tag

    # NOTE:
    # Each phase is overlayed on the next phase. This means that for things that are the same everywhere
    # you are free to simply define it only in Phase4 and all the rest will inherit it.

    ### Release Phase 0 - prd-sam and prd-samtest
    "0": $.per_phase["1"] {
       pilot: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/pilot:a0383b6d85b9e2742777611a33ac778020220ab8",
       proxy: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/proxy:a0383b6d85b9e2742777611a33ac778020220ab8",
       proxyinit: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/proxy_init:a0383b6d85b9e2742777611a33ac778020220ab8",
       sidecarinjector: "ops0-artifactrepo2-0-prd.data.sfdc.net/docker-sfci-dev/sfci/servicemesh/istio-packaging/sidecar_injector:a0383b6d85b9e2742777611a33ac778020220ab8",
       metricsscraper: "ops0-artifactrepo1-0-prd.data.sfdc.net/docker-sam/servicemesh/metrics-scraper:dev",
     },

    ### Release Phase 1 - TBD
    "1": $.per_phase["2"] {
       pilot: "N/A",
     },

    ### Release Phase 2 - TBD
    "2": $.per_phase["3"] {
       pilot: "N/A",
     },

    ### Release Phase 3 - TBD
    "3": $.per_phase["4"] {
       pilot: "N/A",
     },

    ### Release Phase 4 - TBD
    "4": {
       pilot: "N/A",
     },
  },

  ### Phase kingdom/estate mapping
  phase: (
    if kingdom == "prd" then
      "0"
    else if (1 == 2) then
      "1"
    else if (1 == 2) then
      "2"
    else if (1 == 2) then
      "3"
    else if (1 == 2) then
      "4"
  ),

  pilot: imageFunc.do_override_for_non_pipeline_image($.overrides, "pilot", $.per_phase[$.phase].pilot),
  proxy: imageFunc.do_override_for_non_pipeline_image($.overrides, "pilot", $.per_phase[$.phase].proxy),
  proxyinit: imageFunc.do_override_for_non_pipeline_image($.overrides, "pilot", $.per_phase[$.phase].proxyinit),
  sidecarinjector: imageFunc.do_override_for_non_pipeline_image($.overrides, "pilot", $.per_phase[$.phase].sidecarinjector),
  metricsscraper: imageFunc.do_override_for_non_pipeline_image($.overrides, "pilot", $.per_phase[$.phase].metricsscraper),

  # image_functions needs to know the filename of the template we are processing
  # Each template must set this at time of importing this file, for example:
  #
  # "local someteamimages = (import "someteamimages.jsonnet")  + { templateFilename:: std.thisFile };"
  #
  # Then we pass this again into image_functions at time of import.
  templateFilename:: error "templateFilename must be passed at time of import",
  local imageFunc = (import "image_functions.libsonnet") + { templateFilename:: $.templateFilename },
}
