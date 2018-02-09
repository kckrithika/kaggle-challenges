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

    # This is for filtering in, or out, testing clusters.
    is_test_cluster(estate):: (
        estate == "prd-samdev" || estate == "prd-samtest" || estate == "prd-sdc" || estate == "prd-sam" || estate == "prd-sam_storage"
    ),

    # This is for filtering flowsnake clusters.
    is_flowsnake_cluster(estate):: (
        estate == "prd-data-flowsnake" || estate == "prd-data-flowsnake_test" || estate == "prd-dev-flowsnake_iot_test"
    ),

    # This is for filtering Kingdoms which support Ceph Clusters
    is_cephstorage_supported(estate):: (
       estate == "prd-sam" || estate == "phx-sam"
    ),
}
