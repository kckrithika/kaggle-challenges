local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");

# Public functions
{
    # This is for filtering Public Clouds from Private Clouds
    is_public_cloud(kingdom):: (
        kingdom == "cdu" || kingdom == "syd" || kingdom == "yhu" || kingdom == "yul"
    ),

    # This is for filtering GIA
    is_gia(kingdom):: (
        kingdom == "chx" || kingdom == "wax"
    ),

    is_production(kingdom):: (
      kingdom != "prd" &&
      kingdom != "xrd" &&
      kingdom != "crd" &&
      kingdom != "sfz" &&
      kingdom != "crz"
    ),

    # This is for filtering in, or out, testing clusters.
    is_test_cluster(estate):: (
        estate == "prd-samdev" ||
        estate == "prd-samdevpool" ||
        estate == "prd-samtest" ||
        estate == "prd-samtestpool" ||
        estate == "prd-sdc" ||
        estate == "prd-sam" ||
        estate == "xrd-sam" ||
        estate == "prd-sam_storage" ||
        estate == "prd-sam_cephdev" ||
        estate == "prd-sam_sfstoredev" ||
        estate == "prd-sam_storagedev" ||
        estate == "prd-skipper"
    ),

    # This is for filtering flowsnake clusters.
    is_flowsnake_cluster(estate):: (
        estate == "prd-data-flowsnake" ||
        estate == "prd-data-flowsnake_test" ||
        estate == "prd-dev-flowsnake_iot_test" ||
        estate == "iad-flowsnake_prod" ||
        estate == "ord-flowsnake_prod" ||
        estate == "phx-flowsnake_prod" ||
        estate == "frf-flowsnake_prod" ||
        estate == "par-flowsnake_prod"
    ),

    # This is for filtering Kingdoms which support Ceph Clusters
    is_cephstorage_supported(estate):: (
       estate == "prd-sam"
    ),

    # fieldIfNonEmpty allows defining a field in a parent object only if the supplied object is not empty.
    # It is useful in situations where you want to target a field to a specific environment, and omit the
    # field in all other environments.
    #   name: the desired name of the field.
    #   object: the object to test for emptiness. This can be an array, a string, or a JSON object.
    #   value: the value of the field. By default, this is the same as the `object` parameter, though in some
    #          cases it can be useful to supply something other than `object` (e.g., wrapping `object` in
    #          some other JSON object).
    #
    # Examples:
    #   local getNodeAffinityMatchExpressions() = (
    #       // Only use node affinity in prd-sam.
    #       if configs.estate == "prd-sam" then [{
    #           key: "labelkey",
    #           operator: "NotIn",
    #           values: ["a", "b"],
    #       }] else []
    #   );
    #
    #   // getNodeAffinity returns an object with a nodeAffinity field iff getNodeAffinityMatchExpressions
    #   // returns a non-empty array. Otherwise it returns an empty object.
    #   local getNodeAffinity() = (
    #       local matchExpressions = getNodeAffinityMatchExpressions();
    #       fieldIfNonEmpty("nodeAffinity", matchExpressions, {
    #           requiredDuringSchedulingIgnoredDuringExecution: {
    #               nodeSelectorTerms: [{
    #                   matchExpressions: matchExpressions,
    #               }]
    #           }
    #       })
    #   );
    #
    #   // Create a pod spec with an affinity field defined only if getNodeAffinity returns a non-empty object.
    #   local affinity = getNodeAffinity();
    #   ...
    #   spec: {
    #      ...
    #   } + fieldIfNonEmpty("affinity", affinity)
    fieldIfNonEmpty(name, object, value=object):: {
        [if std.length(object) > 0 then name]: value,
    },

    # string_replace returns a copy of the string in which all occurrences of string to_replace have been replaced
    # with string replace_with
    string_replace(str, to_replace, replace_with):: (
            std.join("", std.map(function(x) if x == to_replace then replace_with else x, std.stringChars(str)))
    ),
}
