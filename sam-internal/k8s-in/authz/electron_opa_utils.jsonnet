{
  is_electron_opa_injector_dev_cluster(estate):: (
    estate == "prd-samdev"
  ),

  is_electron_opa_injector_test_cluster(estate):: (
    estate == "prd-samtest"
  ),

  is_electron_opa_injector_prod_cluster(estate):: (
    estate != "prd-samdev" &&
    estate != "prd-samtest"
  ),
}
