local madkub_common = import "madkub_common.jsonnet";
{
    cert_secretizer_config: {
        certToSecretConfigs: [
            {
                type: "TLSSecret",
                secretName: "flowsnake-tls",
                certFileLocation: madkub_common.cert_path("server"),
                keyFileLocation: madkub_common.key_path("server"),
            },
            {
                type: "CASecret",
                secretName: "sfdc-ca",
                certFileLocation: madkub_common.ca_path(),
            },
        ],
    },
}
