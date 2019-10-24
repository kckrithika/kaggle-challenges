local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

{
    ### Per-phase config versions
    per_phase: {

        # NOTE:
        # Each phase is overlayed on the next phase.
        # This means that for things that are the same everywhere,
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
            },

        ### Release Phase 3 - prd-samtwo (production)
        "3": $.per_phase["4"] {
             sfcdapifirebom: "1",
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

    # ====== DO NOT EDIT BELOW HERE ======

    # These are the configs used by the templates
    sfcdapifirebom: $.per_phase[$.phase].sfcdapifirebom,
}
