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

  get_istio_tag(estate):: (
    if $.is_phase1(estate) then "55a0daec53d372a76b261c917a7f06597db1ed2d"
    else if $.is_phase2(estate) then "55a0daec53d372a76b261c917a7f06597db1ed2d"
    else if $.is_phase3(estate) then "f0874ef16fa0c5ea948623884329fe1e0d20e7d5"
    else if $.is_phase4(estate) then "f0874ef16fa0c5ea948623884329fe1e0d20e7d5"
    else if $.is_phase5(estate) then "f0874ef16fa0c5ea948623884329fe1e0d20e7d5"
  ),

  get_service_mesh_tag(estate):: (
    if $.is_phase1(estate) then "6de698dd1935317ebf1ba9d8b5d92207ba8479a6"
    else if $.is_phase2(estate) then "6de698dd1935317ebf1ba9d8b5d92207ba8479a6"
    else if $.is_phase3(estate) then "471d47c97c33ee61a77bd024f20d80603363db75"
    else if $.is_phase4(estate) then "471d47c97c33ee61a77bd024f20d80603363db75"
    else if $.is_phase5(estate) then "471d47c97c33ee61a77bd024f20d80603363db75"
  ),

}
