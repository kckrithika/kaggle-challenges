{
  is_stampy_webhook_dev_cluster(estate):: (
    estate == "prd-samdev"
  ),

  is_stampy_webhook_test_cluster(estate):: (
    estate == "prd-samtest"
  ),

  is_stampy_webhook_prod_cluster(estate):: (
    estate != "prd-samdev" &&
    estate != "prd-samtest"
  ),
}