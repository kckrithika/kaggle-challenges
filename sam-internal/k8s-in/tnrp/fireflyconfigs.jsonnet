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
             fireflyintake: "14",
             fireflycrawler: "14",
             fireflypackage: "14",
             fireflypackagesingleton: "12",
             fireflypromotion: "11",
             fireflypullrequest: "16",
             fireflyevalresultmonitor: "6",
             fireflyrabbitmq: "3",
             fireflyrabbitmqmonitor: "3",
            },

        ### Release Phase 3 - prd-samtwo (production)
        "3": $.per_phase["4"] {
             fireflyintake: "9",
             fireflycrawler: "9",
             fireflypackage: "10",
             fireflypackagesingleton: "8",
             fireflypromotion: "6",
             fireflypullrequest: "11",
             fireflyevalresultmonitor: "2",
             fireflyrabbitmq: "2",
             fireflyrabbitmqmonitor: "2",
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

    # These are the images used by the templates
    fireflyintake: $.per_phase[$.phase].fireflyintake,
    fireflycrawler: $.per_phase[$.phase].fireflycrawler,
    fireflypullrequest: $.per_phase[$.phase].fireflypullrequest,
    fireflypackage: $.per_phase[$.phase].fireflypackage,
    fireflypackagesingleton: $.per_phase[$.phase].fireflypackagesingleton,
    fireflypromotion: $.per_phase[$.phase].fireflypromotion,
    fireflyevalresultmonitor: $.per_phase[$.phase].fireflyevalresultmonitor,
    fireflyrabbitmq: $.per_phase[$.phase].fireflyrabbitmq,
    fireflyrabbitmqmonitor: $.per_phase[$.phase].fireflyrabbitmqmonitor,
}
