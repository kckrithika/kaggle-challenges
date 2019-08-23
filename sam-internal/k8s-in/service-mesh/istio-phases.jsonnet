{
  is_phase1(estate):: (
    estate == "prd-samtest"
  ),

  is_phase2(estate):: (
    estate == "prd-sam"
  ),

  is_phase3(estate):: (
    estate == "par-sam"
  ),

  is_phase4(estate):: (
    estate == "phx-sam"
  ),

  # Deploy to all DCs
  is_phase5(estate):: (
    estate != "prd-samtest" &&
    estate != "prd-sam" &&
    estate != "par-sam" &&
    estate != "phx-sam"
  ),

}
