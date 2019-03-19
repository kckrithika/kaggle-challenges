local madkub_common = import "madkub_common.jsonnet";
local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_v1_enabled then {
    local cert_config = madkub_common.make_cert_config([{ name: "ingresscerts", type: "server" }])[0],
    cert_secretizer_config: {
        certToSecretConfigs: [
            {
                type: "TLSSecret",
                secretName: "flowsnake-tls",
                certFileLocation: cert_config.cert_path,
                keyFileLocation: cert_config.key_path,
            },
            {
                type: "CASecret",
                secretName: "sfdc-ca",
                certFileLocation: cert_config.ca_path,
            },
        ],
    },
} else "SKIP"
