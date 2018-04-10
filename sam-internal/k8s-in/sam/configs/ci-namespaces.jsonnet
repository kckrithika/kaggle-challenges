# Map of namespace to CI namespaces

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
  ],
};


local orgs = ["iot", "ice-pd", "ccait", "atf", "user-sample", "user-vpod", "user-mmittelstadt", "gateway"];

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
