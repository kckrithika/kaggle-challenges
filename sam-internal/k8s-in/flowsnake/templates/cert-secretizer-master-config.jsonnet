{
    certToSecretConfigs: [
        {
                type: "TLSSecret",
                secretName: "flowsnake-tls",
                certFileLocation: "/certs/server/certificates/server.pem",
                keyFileLocation: "/certs/server/keys/server-key.pem",
        },
        {
                type: "CASecret",
                secretName: "sfdc-ca",
                certFileLocation: "/certs/ca.pem",
        },
    ],
}
