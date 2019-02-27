local estate = std.extVar("estate");
local kingdom = std.extVar("kingdom");
local flowsnake_config = import "flowsnake_config.jsonnet";
{
    ajna_applog_logrecordtype_grants: (
        if
            std.objectHas(self.ajna_applog_logrecordtype_grants_data, kingdom + "/" + estate)
        then
            $.ajna_applog_logrecordtype_grants_data[kingdom + "/" + estate]
        else
            error "No matching ajna_applog_logrecordtype_grants entry: " + kingdom + "/" + estate
    ),

    // Map from fleet (kingdom/estate) to map from PKI Namespace to list of Applog Log Record Types.
    // Flowsnake environments in that fleet using that PKI Namespace may access those Applog Log Record Types on Ajna
    // even if they are restricted. (Access to unrestricted Log Record Types does not require enumeration here.)
    ajna_applog_logrecordtype_grants_data: flowsnake_config.validate_kingdom_estate_fields({
        "prd/prd-data-flowsnake": {
            edge_intelligence: [
                "augen",
                "ailtn",
                "u",
            ],
            einstein_analytics_discovery_monitoring: [
                "aprst",
                "G",
                "gglog",
                "gslog",
                "iedfc",
                "iedfs",
                "iedrn",
                "ieece",
                "ieecq",
            ],
            flowsnake: [
                "augen",
                "ailtn",
                "u",
            ],
            "lp-analytics": [
                "augen",
                "ailtn",
                "qasvc",
                "qasql",
                "vavap",
                "vaprf",
                "qapqa",
                "qaprf",
                "qalst",
                "mpmas",
                "atlog",
                "drlay",
                "fpide",
                "fpcrt",
                "pxaqc",
                "dpsbe",
                "dpsbv",
                "A",
                "frval",
                "jslog",
            ],
            search_dlc: [
                "5",
                "Q",
                "ailtn",
                "seabt",
                "seclk",
                "seeps",
                "sepro",
                "serfv",
                "sespc",
                "seuir",
            ],
            "sayonara-applogs": [
                "mqdbg",
                "G",
            ],
        },
        "prd/prd-data-flowsnake_test": {
        },
        "prd/prd-dev-flowsnake_iot_test": {
        },
        "prd/prd-minikube-small-flowsnake": {
            flowsnake: [
                "wxurl",
                "lulog",  //lulog is actually whitelisted anyway
            ],
        },
        "prd/prd-minikube-big-flowsnake": {
            flowsnake: [
                "wxurl",
                "lulog",  //lulog is actually whitelisted anyway
            ],
        },
        "iad/iad-flowsnake_prod": {
        },
        "ord/ord-flowsnake_prod": {
        },
        "phx/phx-flowsnake_prod": {
        },
        "frf/frf-flowsnake_prod": {
        },
        "par/par-flowsnake_prod": {
        },
        "dfw/dfw-flowsnake_prod": {
        },
        "ia2/ia2-flowsnake_prod": {
        },
        "ph2/ph2-flowsnake_prod": {
        },
        "hnd/hnd-flowsnake_prod": {
        },
        "ukb/ukb-flowsnake_prod": {
        },
        "yul/yul-flowsnake_prod": {
        },
        "yhu/yhu-flowsnake_prod": {
        },
        "syd/syd-flowsnake_prod": {
        },
        "cdu/cdu-flowsnake_prod": {
        },
    }),

    // List of unrestricted Ajna Applog Log Record Types that do not require special permission to access. (GDPR compliance)
    ajna_applog_logrecordtype_whitelist: [
        "1",
        "2",
        "3",
        "7",
        "8",
        "9",
        "1acal",
        "1acip",
        "1addv",
        "1adet",
        "1apro",
        "1areg",
        "20jsh",
        "20our",
        "2xads",
        "2xcaa",
        "2xcch",
        "2xgsm",
        "2xham",
        "2xifo",
        "2xmig",
        "2xoft",
        "2xolt",
        "2xoqm",
        "2xpau",
        "2xprs",
        "2xpru",
        "2xpxu",
        "2xshr",
        "2xsoi",
        "2xuto",
        "2xuwd",
        "2xvcu",
        "2xxib",
        "3paco",
        "3pada",
        "3pahc",
        "3paht",
        "3palb",
        "3papl",
        "3pasf",
        "3patf",
        "3paxm",
        "3paxs",
        "3pbfx",
        "3pbtp",
        "3pcdx",
        "3pchb",
        "3pcrt",
        "3pcsp",
        "3pcss",
        "3pcsv",
        "3pcxf",
        "3pdcx",
        "3pdsc",
        "3pdtb",
        "3pfdc",
        "3pfsg",
        "3pfsm",
        "3pftr",
        "3pgac",
        "3pgco",
        "3pgrm",
        "3pgrp",
        "3phad",
        "3phba",
        "3phdp",
        "3phgt",
        "3phpr",
        "3piio",
        "3pint",
        "3pjbs",
        "3pjlg",
        "3pjsc",
        "3pjsy",
        "3pjty",
        "3pjut",
        "3pjvx",
        "3pkfk",
        "3pl4j",
        "3plgw",
        "3pmby",
        "3pmem",
        "3pmma",
        "3pmpa",
        "3pnst",
        "3pntc",
        "3pnty",
        "3poal",
        "3posl",
        "3ppdx",
        "3ppgr",
        "3ppig",
        "3ppki",
        "3ppkk",
        "3ppnx",
        "3pqpd",
        "3pqtz",
        "3prfl",
        "3prfs",
        "3psec",
        "3psem",
        "3psml",
        "3pspa",
        "3pspr",
        "3psrp",
        "3psun",
        "3pswg",
        "3ptfn",
        "3ptlx",
        "3ptrn",
        "3pvgg",
        "3pwdp",
        "3pyrm",
        "3pzkp",
        "a",
        "a1app",
        "aacmn",
        "aacri",
        "aadcm",
        "aadcs",
        "aadde",
        "aadei",
        "aadel",
        "aadfv",
        "aadre",
        "aadsa",
        "aadst",
        "aadtr",
        "aaffo",
        "aapoi",
        "aarcr",
        "aarei",
        "aarfr",
        "aartp",
        "aarun",
        "abusa",
        "accst",
        "actst",
        "aelib",
        "ahahs",
        "ahico",
        "aicml",
        "aivis",
        "alinf",
        "amapp",
        "amcam",
        "amlog",
        "ancje",
        "ancjr",
        "aneml",
        "anhtp",
        "anncj",
        "annmh",
        "anscj",
        "anucj",
        "aocdl",
        "aordl",
        "apbdj",
        "apmas",
        "appnt",
        "aqapi",
        "aqgfe",
        "aqjob",
        "aqpar",
        "aqphx",
        "atsvc",
        "auact",
        "aucst",
        "audep",
        "avarc",
        "avase",
        "avawb",
        "avshp",
        "axbmg",
        "axdia",
        "axext",
        "axfqg",
        "axfqp",
        "axgrp",
        "axhlt",
        "axlim",
        "axmca",
        "axque",
        "axtlt",
        "baerr",
        "baext",
        "basechangequeuemonitor",
        "basePerSolrCoreSystemJob",
        "basePerSolrIndexSystemJob",
        "basePerSolrServerSystemJob",
        "bdblb",
        "bdcls",
        "bdctr",
        "bddpm",
        "bdidx",
        "bdmgr",
        "bdqry",
        "bdscl",
        "bfbas",
        "bfbcp",
        "bfbcs",
        "bfbis",
        "bfbmo",
        "bfbst",
        "bfcnk",
        "bfcop",
        "bfcqm",
        "bfcqp",
        "bfest",
        "bfffx",
        "bfhba",
        "bfhbt",
        "bfhcv",
        "bflis",
        "bflks",
        "bfmsc",
        "bfora",
        "bfrcv",
        "bftcu",
        "bftfl",
        "bigle",
        "biglr",
        "bisaa",
        "bixie",
        "bixif",
        "bixil",
        "bixis",
        "bkjob",
        "btcba",
        "btgle",
        "btglr",
        "btmup",
        "buffalo",
        "c0sim",
        "c0tre",
        "c3htm",
        "c3jsn",
        "capro",
        "causa",
        "cbchr",
        "cdcon",
        "cdddl",
        "cdgap",
        "cdgcu",
        "cdhcp",
        "cdlag",
        "cdlog",
        "cdmne",
        "cdmtk",
        "chcte",
        "chdgl",
        "chdv2",
        "chect",
        "chevt",
        "chfcd",
        "chfce",
        "chfrc",
        "chfue",
        "chgds",
        "chife",
        "chmum",
        "chnot",
        "chpch",
        "chpev",
        "chpfd",
        "chpje",
        "chrmn",
        "chrnd",
        "chvps",
        "cmimq",
        "cmsql",
        "coaqt",
        "cocim",
        "corom",
        "cosjb",
        "cosvj",
        "cpdig",
        "cppst",
        "cpreg",
        "cqqml",
        "cqsqc",
        "csacs",
        "csgcs",
        "ctapx",
        "ctusa",
        "cuaps",
        "cwbsc",
        "cxact",
        "cyenq",
        "cyerr",
        "cylog",
        "cyoss",
        "cyqry",
        "d",
        "dadsp",
        "dbbas",
        "dbmcv",
        "dbpcd",
        "dbpcm",
        "dbsch",
        "dbvot",
        "dcatl",
        "dcbap",
        "dcbar",
        "dcbas",
        "dcchc",
        "dcdac",
        "dcdal",
        "dcdam",
        "dcdap",
        "dcdas",
        "dcdfa",
        "dcdtl",
        "dcnag",
        "dcnjt",
        "dcoth",
        "dcpbm",
        "dereq",
        "dhsav",
        "djdbg",
        "djsav",
        "dnccr",
        "dnsig",
        "dsdbg",
        "dtdag",
        "dtdao",
        "dtdaq",
        "dtdcj",
        "dtdxc",
        "E",
        "e",
        "eadel",
        "eaenq",
        "eaerr",
        "eaflw",
        "eeler",
        "eeoer",
        "eeprf",
        "eesnd",
        "eetrk",
        "ehapx",
        "eidel",
        "eierr",
        "eilog",
        "elgdr",
        "elgrc",
        "elhjb",
        "elsch",
        "emblk",
        "enena",
        "enffe",
        "enmbe",
        "enmte",
        "enval",
        "epusa",
        "errea",
        "ese2s",
        "etrst",
        "evdlv",
        "evlsb",
        "evtrx",
        "ewssm",
        "eyc2c",
        "f",
        "fcapp",
        "ffdel",
        "fffss",
        "ffgen",
        "ffrod",
        "ffssd",
        "ffssm",
        "ffsyn",
        "fhhdl",
        "fhrcl",
        "fhrcp",
        "fhrer",
        "fhrrm",
        "fiusa",
        "fldbg",
        "flsui",
        "fodes",
        "foefk",
        "fooff",
        "forun",
        "fpint",
        "g",
        "gagad",
        "gagrt",
        "garte",
        "gfacc",
        "gfcfg",
        "gfcjs",
        "gfcom",
        "gfcrt",
        "gfdsd",
        "gfdsr",
        "gfdsu",
        "gfenq",
        "gfmhr",
        "gfmtf",
        "gfmtr",
        "gfpjs",
        "gfprf",
        "gfreq",
        "gfsdr",
        "gfslc",
        "gfthr",
        "gfzkl",
        "gllck",
        "H",
        "h",
        "hmhoa",
        "hmhpd",
        "hmhrc",
        "hmhrs",
        "hmhtr",
        "hmrgi",
        "hmrmr",
        "hsmsg",
        "hssig",
        "htbmh",
        "htbms",
        "htfdc",
        "htjcp",
        "htjfx",
        "htmcp",
        "htocp",
        "htxty",
        "hurll",
        "idcpe",
        "idese",
        "idlel",
        "idlog",
        "idssl",
        "ieapi",
        "iebat",
        "iebbr",
        "iebco",
        "iebcp",
        "ieber",
        "iebfs",
        "iebin",
        "iebpf",
        "iebro",
        "iedow",
        "iedsc",
        "iedss",
        "iedvw",
        "iedwc",
        "ieeci",
        "ieecm",
        "ieepm",
        "iemes",
        "ienlp",
        "ienlq",
        "ietrg",
        "ietsa",
        "ietsj",
        "iewol",
        "iexmd",
        "ihinf",
        "ihreq",
        "ihsub",
        "incmp",
        "iobat",
        "ioeml",
        "ioerr",
        "ioicu",
        "ioiod",
        "ioior",
        "ioiou",
        "iouse",
        "iqdbg",
        "iqeaa",
        "iqerr",
        "iqetc",
        "iqinf",
        "iqins",
        "iqrpt",
        "iqtrf",
        "iqwrn",
        "iqxca",
        "iqxcp",
        "iqxcr",
        "iqxcs",
        "iqxeb",
        "iqxej",
        "iqxet",
        "iqxkg",
        "iqxkr",
        "iqxok",
        "iqxot",
        "iqxsb",
        "iqxsc",
        "iqxst",
        "iqxub",
        "iqxuc",
        "iqxud",
        "iqxuk",
        "iqxus",
        "iqxuu",
        "iqxuv",
        "iserr",
        "islog",
        "jpcmd",
        "jphnd",
        "jprpl",
        "jwgwt",
        "jwind",
        "K",
        "kbevh",
        "kcasp",
        "kmint",
        "kmpdt",
        "kpcpu",
        "kpdbg",
        "kpdsk",
        "kpmem",
        "kpnet",
        "kpprc",
        "krapp",
        "ksbse",
        "ksecm",
        "ksgen",
        "ksjob",
        "ksksp",
        "kskst",
        "kslem",
        "ksscr",
        "ksscw",
        "kssjs",
        "lbutl",
        "lcbas",
        "lclip",
        "lcreq",
        "ldswp",
        "lesav",
        "lesrc",
        "lfinf",
        "lhsta",
        "lmsql",
        "lmtim",
        "lplpl",
        "lpmdl",
        "lpprg",
        "lpstp",
        "lsbas",
        "ltcpy",
        "lulog",
        "lvpop",
        "lzapp",
        "M",
        "m",
        "madep",
        "mades",
        "madop",
        "madvt",
        "maevt",
        "maopr",
        "maoqp",
        "mares",
        "maret",
        "marou",
        "marvt",
        "mazip",
        "mblog",
        "mdact",
        "meidx",
        "melog",
        "mepbm",
        "mgreq",
        "mhcli",
        "mhspy",
        "mkact",
        "mlmul",
        "mmdbg",
        "mmspe",
        "mmspr",
        "mmspt",
        "mnfmh",
        "mnsmp",
        "mqast",
        "mqbst",
        "mqcdc",
        "mqcoa",
        "mqcol",
        "mqdas",
        "mqded",
        "mqdeq",
        "mqdmt",
        "mqend",
        "mqenq",
        "mqfld",
        "mqflq",
        "mqfrm",
        "mqfua",
        "mqfue",
        "mqfui",
        "mqfuq",
        "mqhal",
        "mqhdl",
        "mqlrt",
        "mqlwt",
        "mqlzy",
        "mqqbu",
        "mqqhc",
        "mqrar",
        "mqreq",
        "mqrsj",
        "mqrur",
        "mqscq",
        "mqslc",
        "mqslt",
        "mqsos",
        "mqspe",
        "mqsps",
        "mqsru",
        "mqssv",
        "mqswp",
        "mqtrn",
        "mqtxn",
        "mrexe",
        "mrusa",
        "mwupg",
        "mxshs",
        "mzbps",
        "njcnv",
        "njecr",
        "njmfu",
        "njpar",
        "njres",
        "njttl",
        "nlapi",
        "noahe",
        "nobcr",
        "nobgd",
        "nobgt",
        "nobpr",
        "nobuc",
        "nodce",
        "nofan",
        "nofba",
        "nofbp",
        "nogrd",
        "nohdy",
        "nontm",
        "noper",
        "ntads",
        "nwavc",
        "nwcsp",
        "nwmcm",
        "nwmoa",
        "nwmom",
        "nwptc",
        "nwtal",
        "nwtra",
        "nwtrc",
        "opjob",
        "oserr",
        "oslog",
        "oxdnl",
        "oxeds",
        "oxerr",
        "oxexp",
        "oxmsg",
        "oxusr",
        "P",
        "p",
        "p8exc",
        "p8log",
        "pabas",
        "pasrv",
        "pbchp",
        "pbcpl",
        "pbcpm",
        "pdddr",
        "pddlp",
        "pdhbd",
        "pdlog",
        "pdmon",
        "pecre",
        "perorgcommon",
        "pffin",
        "pgdsp",
        "pgwrk",
        "phacq",
        "pherr",
        "phmet",
        "phrsc",
        "piinf",
        "pmbuf",
        "pmces",
        "pmevt",
        "pmgrc",
        "pmhec",
        "pmims",
        "pmtpt",
        "pmvpr",
        "pncrn",
        "pnfbk",
        "pv0",
        "pvago",
        "pvdeq",
        "pvenq",
        "pverr",
        "pvlic",
        "pvmon",
        "pvmsg",
        "pvorg",
        "pvprh",
        "pvprm",
        "pvprt",
        "pvpsl",
        "pvpsr",
        "pvqtm",
        "pvsop",
        "pvtim",
        "pvtst",
        "pyblc",
        "pyble",
        "pybli",
        "pyseq",
        "pzcon",
        "qaedt",
        "qifim",
        "qiful",
        "qipmi",
        "qires",
        "qiscl",
        "qqape",
        "qqfpp",
        "qqgce",
        "qqopp",
        "qqpgm",
        "qqpmc",
        "qqprf",
        "qqpsr",
        "qqsar",
        "qqsea",
        "qqutp",
        "qqxsm",
        "qqxsr",
        "qqxss",
        "qxjob",
        "r",
        "racri",
        "rapoi",
        "rarei",
        "rarun",
        "rcapl",
        "rcdbg",
        "rclag",
        "rdlog",
        "refvu",
        "reops",
        "reotr",
        "rercp",
        "rerfu",
        "rerpt",
        "rfkaf",
        "ribde",
        "risav",
        "risde",
        "riswp",
        "rmrps",
        "rpclc",
        "rpclg",
        "rpclp",
        "rpdbg",
        "rpdel",
        "rpidx",
        "rprc2",
        "rprc3",
        "rpsvf",
        "rpsvg",
        "rpsvl",
        "rpsvm",
        "rptme",
        "rslog",
        "rxrll",
        "rycnk",
        "rygnl",
        "s",
        "s0opr",
        "s0scr",
        "s2isr",
        "s2mbs",
        "s2plg",
        "s2ppe",
        "s2qbp",
        "s2que",
        "s2rec",
        "s2res",
        "s2sar",
        "s2sbi",
        "s2sds",
        "s2usr",
        "s2xir",
        "sabut",
        "sacom",
        "sagpm",
        "saowd",
        "sapjt",
        "sapro",
        "sarci",
        "sarct",
        "sarrp",
        "sarst",
        "sascr",
        "sasdc",
        "sasdm",
        "saslk",
        "sasrr",
        "sasts",
        "satai",
        "satar",
        "savis",
        "scesc",
        "scgen",
        "scinv",
        "sdccc",
        "sdcsc",
        "sdcwc",
        "sdusa",
        "seaiw",
        "seaqt",
        "searchIndexBackup",
        "searchsnippetsbasic",
        "sebem",
        "sebtt",
        "sedip",
        "sefql",
        "segap",
        "sehdp",
        "seibp",
        "seinc",
        "senbp",
        "sepes",
        "serdo",
        "seren",
        "sescc",
        "sesci",
        "sesnp",
        "sesrt",
        "setal",
        "setrm",
        "sevis",
        "sgact",
        "sgbsc",
        "sgcre",
        "sgdel",
        "sgdis",
        "sgfin",
        "sgogc",
        "sgoix",
        "sgref",
        "sgtrn",
        "shdqc",
        "shmce",
        "sksdy",
        "slcln",
        "sllrq",
        "slmom",
        "slmub",
        "slmud",
        "smcnl",
        "smdri",
        "smevt",
        "sminf",
        "smreq",
        "smtim",
        "sobkp",
        "sobpc",
        "sobrp",
        "socbk",
        "socei",
        "sochi",
        "sochk",
        "sochm",
        "sochp",
        "socqr",
        "socqu",
        "socrp",
        "socrt",
        "sodel",
        "soevp",
        "sofan",
        "soicv",
        "soimp",
        "soirt",
        "somvc",
        "soorg",
        "sopbk",
        "sopbs",
        "sopgp",
        "sopng",
        "soptc",
        "soreb",
        "sosiv",
        "sosli",
        "sospq",
        "sospt",
        "sostg",
        "sosvp",
        "sovlp",
        "sqact",
        "squpl",
        "srerr",
        "srold",
        "srrun",
        "srtxt",
        "sscer",
        "sscex",
        "sschk",
        "sscim",
        "sscmc",
        "sscop",
        "sscqu",
        "sscsz",
        "ssent",
        "ssmsg",
        "ssovr",
        "sssog",
        "sstxt",
        "ssxic",
        "sxabt",
        "sxcpy",
        "sxdim",
        "sxerr",
        "sxgen",
        "sxinf",
        "sxoid",
        "sxopt",
        "sxpct",
        "sxpdc",
        "sxsbo",
        "sxsch",
        "sxsdp",
        "sxsmp",
        "sxsql",
        "sxtbl",
        "tfchk",
        "tfcqu",
        "tfent",
        "tferr",
        "tfinf",
        "tfovr",
        "thcon",
        "thdeq",
        "therr",
        "thoim",
        "tkcou",
        "tkdfc",
        "tloio",
        "tmjob",
        "tnlvw",
        "togen",
        "tosas",
        "tpner",
        "tptsk",
        "tpujr",
        "tpusd",
        "tzapx",
        "tzorg",
        "u",
        "udcpe",
        "uddwn",
        "udfkc",
        "udjrr",
        "udldd",
        "udldt",
        "udmnv",
        "udpkg",
        "udprs",
        "udrvi",
        "udrvw",
        "udstp",
        "ueper",
        "ueueb",
        "ueuec",
        "ueurp",
        "umcdq",
        "umceq",
        "usast",
        "usblk",
        "userr",
        "usmvi",
        "usrcl",
        "usrin",
        "ussts",
        "vcsin",
        "vcsop",
        "vsscn",
        "vsspm",
        "W",
        "waupg",
        "wdlog",
        "wfaem",
        "wfdbg",
        "wfemm",
        "wftqe",
        "wftwf",
        "wousa",
        "X",
        "x2err",
        "xasaa",
        "xccsv",
        "xcdac",
        "xcgen",
        "xcpkc",
        "xcrcj",
        "xcsvc",
        "xcund",
        "xdajs",
        "xdapl",
        "xdcls",
        "xdcon",
        "xdidd",
        "xdidx",
        "xdsqp",
        "xdsqs",
        "xocud",
        "xodes",
        "xofpt",
        "xohmg",
        "xoqry",
        "xorsv",
        "xosyn",
        "xserr",
        "xslog",
        "xxdbg",
        "Y",
        "Z",
        "z",
        "zclog",
        "zeaxd",
        "zero0",
        "zerox",
        "zslog",
        "zzbas",
        "zzbcy",
        "zzdrn",
        "zzldr",
        "zzlog",
        "zzpcm",
        "zzpub",
    ],

}
