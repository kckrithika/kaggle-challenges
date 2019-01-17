local flowsnakeconfig = import "flowsnake_config.jsonnet";

# TODO: sam audodeployer needs to support this type
if false then
{
    apiVersion: "admissionregistration.k8s.io/v1beta1",
    kind: "MutatingWebhookConfiguration",
    metadata: {
        name: "madkub-injector-webhook",
        namespace: "flowsnake",
    },
    webhooks: [{
        name: "madkub-injector.flowsnake.sfdc.net",
        failurePolicy: "Fail",
        clientConfig: {
			# Bug in 1.9.7 requires this. This is the Infra CA Level 2 - not that it matters, because system roots include SFDC and can validate the webhook cert.
            caBundle: "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUY3ekNDQTllZ0F3SUJBZ0lVQVFNZ0VaQ2tBZnhJV1pUZ1EzZms0ak9RRW00d0RRWUpLb1pJaHZjTkFRRUwKQlFBd2dZc3hDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFJREFwRFlXeHBabTl5Ym1saE1SWXdGQVlEVlFRSApEQTFUWVc0Z1JuSmhibU5wYzJOdk1SMHdHd1lEVlFRS0RCUnpZV3hsYzJadmNtTmxMbU52YlN3Z2FXNWpMakV3Ck1DNEdBMVVFQXd3bmMyRnNaWE5tYjNKalpTNWpiMjBnU1c1MFpYSnVZV3dnVW05dmRDQkRRU0F5SUVsdVpuSmgKTUI0WERURTNNRGN5T0RFNU5UQXhNbG9YRFRJeU1EY3lOekU1TlRBeE1sb3dnWTh4Q3pBSkJnTlZCQVlUQWxWVApNUk13RVFZRFZRUUlEQXBEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIREExVFlXNGdSbkpoYm1OcGMyTnZNUjB3Ckd3WURWUVFLREJSellXeGxjMlp2Y21ObExtTnZiU3dnYVc1akxqRTBNRElHQTFVRUF3d3JjMkZzWlhObWIzSmoKWlM1amIyMGdTVzUwWlhKdVlXd2dRMEVnTWtFZ1NXNW1jbUV0VEdWMlpXd2dNVENDQWlJd0RRWUpLb1pJaHZjTgpBUUVCQlFBRGdnSVBBRENDQWdvQ2dnSUJBS0NBQXlLSkRmL0swOWczWUNrWVc2OVpZV2U0Ti9WeGRMN21ocW0vCkN3ZlBiRXlQWEZkY3VDeE02NWMwUEZHNlNjNnpTSDVYVlZCd0VmSkVHRnIrczZtdDBrRlQxd2FRclR1ZFBRZnUKdDI1aUZpYXU1SVJZdVpEWEFOQndjU1ZUYWk2bTlBN0crZUxrM05nWi9aMmFDc2kyNkU5bDFKbVZBRkJDeGFkVAo3dGY2U0tKM1lncTc2ZW44ZjY5WVAvdjFQMm1pV0RtMXlWemg1WC8yK1hyWVRwa3hjTlVMaFN0dmNydEVLdXc4CjZsa3h5NHJJaDJlQmhWcXpHcmVQOGR1N0hWQllJSklHZnJ4SEpMVTVsMmdGZWY4aWR5bUYvNG5aaXdxZ0ZVN1kKc3Z6VFhGZTh5YUxHdUVQQUUzU2ptdFd2Ylh6VHRvQmNBVlB6WS9ILytRUGVnMGF0b1BnelpiNUU0QVhMVmxNSQpDQkxhbzRvVTB4MFZURjhvNXJyWDBlK25mZTF0a1VQOEE3T1JybXJUTVVZczZGTEVoSVNpZWtXcXRaNDh3S0xRCmtkcUc3K2MzZlc4SkFkN0MwbGZEenkxSnRINmEvcWVxbHVvWjl1d1Y3ZXFZRVFoUzFVQjRhTXB1c2w1Y2w2dFUKejl4T01aclFydDhWSWhMcmo0LzFxZ1FoOWo5RVVkQmFwbHBTL1NLb3FjVzFNcmRpOUltcWY0RVZYcytpdzZlLworWUQyK3grU1lPREM0dFh1Y2VXaCtycm9qM1NoMUFQN2pxc3oxMzI0WG84OUNkdS9EdDJWeEFQMUxTQmFHcVAxCjdyazBhNm9sbHRKQU4rU0VYL0QxcldycVdEdlJtTGQwdmh0bE1nTGtESjVOeTFzRU82ZjZzK0ErMU5GZU1lQ1oKdURITkFnTUJBQUdqUlRCRE1CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRSXdEZ1lEVlIwUEFRSC9CQVFEQWdFRwpNQjBHQTFVZERnUVdCQlJldFdJRE5tYit1OWk4YkpxeGx1cmdvdWRhdmpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DCkFnRUFsY3lvTDBwVU5VSHZUZERlV2dkd2JKaXd0K0NpWFA0bGE1RHdqejNvejk1VVIxUWpuZlo2ODJyRUtjbEYKbW5qakNlUTVmN3FJUEhUd2ZNWTBKWjVUQVpySHpoWCs4R0Fxb2R4QXo3cGxwcVlWclErN3lKcm1xbXNnZnQrNwptNVozVitCcENJVXpqLzJDL3BPY2lBdXByN0J3MytQVFh4MTA0cjR4MVlqLzUrQk1SU3h3UThSWWY5TGlveVdjClNEMityZDJ1NTN0aElxQnA1N3BDQ1NjSDNRcUNsMkNrQVY5UWRQR0lsRWJzSTJlbU5MU0dtYW43bUI1b3FxWEUKVmFod2dhVGtnaDg0RWhzWkJuQmsrME5iWDIyTE93dkl2dEp0UkpFc2JvbktGcmZtTTFmRkxsNXB3cEFTblZtQwp3TjN5eEpzQ095RHBId2ZwVXE4Rkp2WXFBbksxajFkVmRUTlpKYTNHR1pYc0Noa1cvbzFHRUtrbktwU1ByaVR3CkZyN3lRemRCRStZV1lUcVkyQXh0YkdNVG52SmYzWFhyZS9HQytEQXFYNk00Q1pTazdpTUN1MENyMnlIQ1JUMk0KbERkcmdMeTUvMzBwSzRqS2JPVXphd3JlOExzZk5CenBiZWJiOVJyR2JxeDVKTHBFZ25vU202MHNOYW1uVU1qNQpBQ01ZWTVpWmorY25EMzBOd2xOYkVzZ0t4dThaOXA2akw2TzJOWDJPRllWSW9adCsvaUVJNFMxYktTNVdqQXpQCmVDcU14RmZPZGtWcm5venFzaC82NjhFQjY3TjZjUkdKN2RyeG9rdm9oS1E3OWkwQktMKzdHYlEvU3Z3Z1Qzb1YKYkFhQXJJbzd4akUyNUd0dWFCUFZzTHdST0tjRzdzd3owOHhxY0Z4alpkUTRWRFE9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
            service: {
                name: "madkub-injector",
                namespace: "flowsnake",
                path: "/"
            }
        },
        rules: [{
            operations: [ "CREATE", "UPDATE" ],
            apiGroups: [""],
            apiVersions: ["v1"],
            resources: ["pods"],
        }],
        namespaceSelector: {
            matchLabels: {
                "madkub-injector": "enabled"
            }
        }
    }]
} else "SKIP"
