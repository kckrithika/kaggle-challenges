local estate = std.extVar('estate');
local kingdom = std.extVar('kingdom');
local utils = import 'util_functions.jsonnet';
local configs = import 'config.jsonnet';

{
  // Releases should follow the order below unless there are special circumstances.  Each phase should use the
  // image from the previous stage after a 24 hour bake time with no issues (check that all watchdogs are healthy)
  //#
  //## Global overrides - Anything here will override anything below
  overrides: {
    //
    // This section lets you override any consul image for a given kingdom,estate,template,image.
    // Image name
    //
    // Example:
    //   # [alias] Added this override to fix issue xxx
    //   "prd,prd-samtwo,consul,consul": "xxxxx",

  },

  //## Per-phase image tags
  per_phase: {
    //## Release Phase 0 - for sam and samtest
    '0': $.per_phase['1'] {
      consul: '142-20190212-3',
    },

    //## Release Phase 1 - TBD
    '1': $.per_phase['2'] {
      consul: 'N/A',
    },

    //## Release Phase 2 - TBD
    '2': $.per_phase['3'] {
      consul: 'N/A',
    },

    //## Release Phase 3 - TBD
    '3': $.per_phase['4'] {
      consul: 'N/A',
    },

    //## Release Phase 4 - TBD
    '4': {
      consul: 'N/A',
    },
  },

  //## Phase kingdom/estate mapping
  //## consul only deploys to GKE sam for now - other stages are TBD
  phase: (
    if (kingdom == 'mvp') then
      '0'
    else if (1 == 2) then
      '1'
    else if (1 == 2) then
      '2'
    else if (1 == 2) then
      '3'
    else
      '4'
  ),

  consul: 'ops0-artifactrepo2-0-xrd.slb.sfdc.net/docker-devmvp/ameesala/consul-ts:' + $.per_phase[$.phase].consul,

  templateFilename:: error 'templateFilename must be passed at time of import',
  //TODO: use imageFunc.do_override_* once pipelines are setup
  //  local imageFunc = (import 'image_functions.libsonnet') + { templateFilename:: $.templateFilename },
  // These are the images used by the templates
}
