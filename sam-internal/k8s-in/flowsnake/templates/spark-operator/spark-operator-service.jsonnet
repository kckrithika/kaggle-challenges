{
    apiVersion: "v1",
    kind: "Service",
    metadata: {
        name: "spark-webhook",
        namespace: "flowsnake",
    },
    spec: {
        ports: [{
            port: 443,
            targetPort: 8443
        }],
        selector: {
			"app.kubernetes.io/name": "spark-operator",
        },
    }
}
