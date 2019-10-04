local configs = import "config.jsonnet";
local utils = import "util_functions.jsonnet";

# The purpose of this file is to maintain a central set of booleans for new services that
# we slowly roll from a small set of kingdoms/estates to everywhere for safety reasons.
# By defining these flags centrally we dont need to copy-paste the same if statements across
# many templates.
#
# This is not intended for kingdom/estate selection for something that by-design will only run
# in a small subset of places.  (Like our jenkins runs only in prd-sam and has no plans to run in prod)

{
     servicemeshResiliency:
       configs.estate == "prd-samtest",
}
