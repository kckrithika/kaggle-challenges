{
  local set_value_to_all_in_list(value, list) = { [item]: value for item in list },
  local set_value_to_all_in_list_skip(value, list, skip) = { [item]: value for item in list if item != skip },

  prodKingdoms: ['frf', 'phx', 'iad', 'ord', 'dfw', 'hnd', 'xrd', 'cdg', 'fra', 'ia2', 'ph2', 'par', 'ukb', 'lo2', 'lo3'],
  slbKingdoms: $.prodKingdoms + ['prd'],
  prodEstates: [k + '-sam' for k in $.slbKingdoms] + ['prd-samtwo'],
  testEstates: ['prd-sdc', 'prd-samdev', 'prd-samtest', 'prd-sam_storage'],

  # The set of VIPs which are served on the hsm pipeline. This is in addition to any VIPs specified in
  # hsmDefaultEnabledVips below.
  hsmEnabledVips:
    set_value_to_all_in_list([], $.testEstates)
    + set_value_to_all_in_list([], $.prodEstates)
    + {
      'prd-sam': [
        'mist51-app-hsm-prd.slb.sfdc.net',
        'mist51-app-prd.slb.sfdc.net',
         # Steven Lawrance (@slawrance) KMS testing in PRD 2019/06/03
        'encinoman1-slawrance-prd.slb.sfdc.net',
        'encinoman2-slawrance-prd.slb.sfdc.net',
        'encinoman3-slawrance-prd.slb.sfdc.net',
        'encinoman4-slawrance-prd.slb.sfdc.net',
        'encinoman5-slawrance-prd.slb.sfdc.net',
        'encinoman6-slawrance-prd.slb.sfdc.net',
        'encinoman1-cs2-slawrance-prd.slb.sfdc.net',
        'encinoman2-cs2-slawrance-prd.slb.sfdc.net',
        'encinoman3-cs2-slawrance-prd.slb.sfdc.net',
        'encinoman4-cs2-slawrance-prd.slb.sfdc.net',
        'encinoman5-cs2-slawrance-prd.slb.sfdc.net',
        'encinoman6-cs2-slawrance-prd.slb.sfdc.net',
        'vonage-mist51-na1-slawrance-prd.slb.sfdc.net',
        'petco-mist51-na1-slawrance-prd.slb.sfdc.net',
        'petco2-mist51-na1-slawrance-prd.slb.sfdc.net',
      ],
      'prd-samtwo': [
        'na44-stmfa1-0-prd.slb.sfdc.net',
        'na44-stmfb1-0-prd.slb.sfdc.net',
      ],
      'phx-sam': [
        'login-cloudforce-phx.slb.sfdc.net',
        'gs0-bofa-phx.slb.sfdc.net',
      ],
      'dfw-sam': [
        'login-cloudforce-dfw.slb.sfdc.net',
        'gs0-bofa-dfw.slb.sfdc.net',
      ],
    },
}
