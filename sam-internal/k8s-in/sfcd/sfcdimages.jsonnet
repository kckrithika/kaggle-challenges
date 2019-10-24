local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local utils = import "util_functions.jsonnet";
local configs = import "config.jsonnet";

{
    # ================== SFCD RELEASE ====================
    # Releases should follow the order below unless there are special circumstances.  Each phase should use the
    # image from the previous stage after a 24 hour bake time with no issues (check that all watchdogs are healthy)
    ###

    ### Global overrides - Anything here will override anything below
    overrides: {
        #
        # This section lets you override any Firefly image for a given kingdom,estate,template,image.
        # Image name
        #
        # Example:
        #   # [alias] Added this override to fix issue xxx
        #   "prd,prd-samtwo,firefly-rabbitmq-rcs,rabbitmq": "xxxxx",

        },

    ### Per-phase image tags
    per_phase: {

        ### Release Phase 0 - Nightly deployment of the most recent firefly to prd-samtest
        # Under normal cirumstances we should not need to change this section.
        # Overrides work just fine in this phase.

        # NOTE:
        # Each phase is overlayed on the next phase.  This means that for things that are the same everywhere
        # you are free to simply define it only in Phase4 and all the rest will inherit it.

        ### Release Phase 0 - prd-samtest
        "0": $.per_phase["1"] {
             },

        ### Release Phase 1 - prd-samdev
        # See https://git.soma.salesforce.com/sam/sam/wiki/Deploy-SAM on how to pick the correct tag
        # As much as possible, we want to use a tag that is running well in phase 0 above.
        # When rolling this phase, remove all overrides from test beds above
        # Make sure there are no critical watchdogs firing before/after the release, and check emails to make sure all rolled properly

        ### Release Phase 1 - prd-samdev
        "1": $.per_phase["2"] {
            },

        ### Release Phase 2 - prd-sam (Canary)
        "2": $.per_phase["3"] {
             sfcdapifirebom: "24",
            },

        ### Release Phase 3 - prd-samtwo (production)
        "3": $.per_phase["4"] {
             sfcdapifirebom: "24",
            },

        ### Release Phase 4 - Rest of Prod + Pub + Gia
        "4": {
            },
        },

    ### Phase kingdom/estate mapping
    phase: (
        if (estate == "prd-samtest") then
            "0"
        else if (estate == "prd-samdev") then
            "1"
        else if (estate == "prd-sam") then
            "2"
        else if (estate == "prd-samtwo") then
            "3"
        #else
        #    "4"
        ),

    # Static images that do not go in phases
    # [Important Note]: When you are changing images in for initContainers/sidecars  they are not promoted to prod by default. This need to be
    # fixed in the image promotion logic in SMB. For now the workaround is to update the image of a watchdog in one prod DC so that the image is promoted
    # Please be very careful when making such a change
    static: {


    },

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the images used by the templates
    sfcdapifirebom: configs.registry + "/dva/sfcdapi-firebom:" + $.per_phase[$.phase].sfcdapifirebom,

}
