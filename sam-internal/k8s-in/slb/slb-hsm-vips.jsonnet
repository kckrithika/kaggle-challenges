{
  local set_value_to_all_in_list(value, list) = { [item]: value for item in list },
  local set_value_to_all_in_list_skip(value, list, skip) = { [item]: value for item in list if item != skip },
  local slbhsmvips = import "slbhsmvips.json",


  prodKingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd', 'xrd', 'cdg', 'fra', 'ia2', 'ph2', 'par', 'ukb', 'lo2', 'lo3', 'ia4', 'ia5'],
  slbKingdoms: $.prodKingdoms + ['prd'],
  prodEstates: [k + '-sam' for k in $.slbKingdoms] + ['prd-samtwo'],
  testEstates: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage'],

  # The set of VIPs which are served on the hsm pipeline. This is in addition to any VIPs specified in
  # hsmDefaultEnabledVips below.
  hsmEnabledVips:
    set_value_to_all_in_list([], $.testEstates)
    + set_value_to_all_in_list([], $.prodEstates)
    + slbhsmvips,
}
