# Map of namespace to CI namespaces
local configs = import "config.jsonnet";

 # teams want additional namespace other than "ci-team" namespaces
local ci = {
  additionalNs: [
  {
    team: "atf",
    namespace: "ci-atf-dev",
  },
  {
    team: "atf",
    namespace: "ci-atf-mirror",
  },
  {
      team: "atf",
      namespace: "ci-atf-mit-dev",
  },
  {
      team: "atf",
      namespace: "ci-atf-mit-mirror",
  },
  {
        team: "atf",
        namespace: "ci-atf-mit",
    },
  ]
  + (if configs.estate == "prd-samdev" then [{
    team: "csc-sam",
    namespace: "csc-sam",
  }] else []),
};


local orgs = [
    "iot",
    "ice-pd",
    "ccait",
    "atf",
    "user-sample",
    "user-vpod",
    "user-mmittelstadt",
    "gateway",
    "search-scale-safely",
    "core-on-sam",
    "retail-dfs",
    "retail-cre",
    "retail-rsui",
    "retail-mds",
    "emailinfra",
    "global-identity",
    "cloudatlas",
    "cast",
];

{
  namespacesToTeam: {
    ['ci-' + x]: x
for x in orgs
  }
+ {
    [c.namespace]: c.team
    for c in ci.additionalNs
  },
}
