local configs = import "config.jsonnet";
local versions = import "authz/versions.jsonnet";
local electron_opa_utils = import "authz/electron_opa_utils.jsonnet";
local utils = import "util_functions.jsonnet";

if electron_opa_utils.is_electron_opa_injector_prod_cluster(configs.estate) && electron_opa_utils.can_deploy(configs.kingdom) then
{
  apiVersion: "admissionregistration.k8s.io/v1beta1",
  kind: "MutatingWebhookConfiguration",
  metadata: {
    name: "electron-opa-injector-cfg",
    labels: {
      app: "electron-opa-injector",
    },
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  webhooks: [
    {
      name: "electron-opa-injector.authz.svc",
      clientConfig: {
        url: "https://electron-opa-injector.%s.svc%s:17442/mutate" % [versions.newInjectorNamespace, "." + configs.dnsdomain],
        caBundle: "IwojIFRISVMgRklMRSBJUyBGT1IgUFJPRFVDVElPTiBPTkxZCiMKIyBOT1RFOiBETyBOT1QgTEVBVkUgQU4gRU1QVFkgTElORSBBVCBUSEUgRU5EIE9GIFRISVMgRklMRQojCiMgVXNlOiBrZXl0b29sIC1wcmludGNlcnQgLXYgLWZpbGUgY2FjZXJ0cy5wZW0KIwojCiMgT3duZXI6IENOPXNhbGVzZm9yY2UuY29tIEludGVybmFsIFJvb3QgQ0EgMSwgTz0ic2FsZXNmb3JjZS5jb20sIGluYy4iLCBDPVVTCiMgSXNzdWVyOiBDTj1zYWxlc2ZvcmNlLmNvbSBJbnRlcm5hbCBSb290IENBIDEsIE89InNhbGVzZm9yY2UuY29tLCBpbmMuIiwgQz1VUwojIFNlcmlhbCBudW1iZXI6IGRhZDI4ZDg0M2ZjNzMzMjVkNGMxYTc1MjA3ZDRlNzQKIyBWYWxpZCBmcm9tOiBUaHUgTWF5IDI2IDE3OjAwOjAwIFBEVCAyMDE2IHVudGlsOiBUdWUgTWF5IDI2IDE2OjU5OjU5IFBEVCAyMDI2CiMKLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZmekNDQTJlZ0F3SUJBZ0lRRGEwbzJFUDhjekpkVEJwMUlIMU9kREFOQmdrcWhraUc5dzBCQVFzRkFEQlkKTVFzd0NRWURWUVFHRXdKVlV6RWRNQnNHQTFVRUNoTVVjMkZzWlhObWIzSmpaUzVqYjIwc0lHbHVZeTR4S2pBbwpCZ05WQkFNVElYTmhiR1Z6Wm05eVkyVXVZMjl0SUVsdWRHVnlibUZzSUZKdmIzUWdRMEVnTVRBZUZ3MHhOakExCk1qY3dNREF3TURCYUZ3MHlOakExTWpZeU16VTVOVGxhTUZneEN6QUpCZ05WQkFZVEFsVlRNUjB3R3dZRFZRUUsKRXhSellXeGxjMlp2Y21ObExtTnZiU3dnYVc1akxqRXFNQ2dHQTFVRUF4TWhjMkZzWlhObWIzSmpaUzVqYjIwZwpTVzUwWlhKdVlXd2dVbTl2ZENCRFFTQXhNSUlDSWpBTkJna3Foa2lHOXcwQkFRRUZBQU9DQWc4QU1JSUNDZ0tDCkFnRUF2R01Fa2ZZdW1WM2dmWS9jY3VFaHh0bHNWbjJ6WnU4VUwzS2NLYkQwMEduTmhFOVRTblBLb3pPMjBxMHIKQlVUcUVsRlRFS2JnZTBhUFZXU3lCd0dGZDdZdm1ZcS9FOENON1N5b2I0QXZwQjAzZEljNGhSRGlqSC9WcFNEZAp1bzVIeEsrQUxCa3FwcFFqaWRnaXNTUW1rOFUwek9tSWh6K203Z1ozV1hvVmFVakdaVnc2VTM0V09HTWU1b0FqCjFIOHVWcG9mOTVDL0t6RFFaeHlDQVJjc0dwZlNLUEEyTC83cDBiWVBMUHh6RXNKNW13Um9GNTE0di94UDBmdHQKLzR0NnJrZERsOXFDZGFkR2YrMmxXWVRxdjVWWjE4NW16eEcvMkVuUGoySVFmTWVkWkE0dzRyWnoweFpKNThQdQp2YU5tNnZnZVNtTDZxZlFvSWxQRDJZdVZ5ZlcyL2YyZkJwckgrK1hCeWFKbGFtcXNFcU1La0VueE5OQXFsY2lzCmFvTHNrMW9TQTBYTUNubmd5bkQxR2JvRXRwdG9vS1ZIZFp6L1E1TVlVeXFlcTRxMStNL0k3ZEhFVm5wTjlFSC8KUnFUbVFnQWRTbGNjYisvQVR2aDE2U3QvcENsWFNZTkk4Q3pZOVhCNEZoZVZLbVFZYVExbWZGc3lwTElocllreQpzZVFBZHBGcFZjZFBSSS9GWGpwa0NjNkJhNDNIVE42d2F0b0N0alBaTjRBNHJRazZyTHdoSVAySmpJOTRFV1lPCmU2aWFPb1BvUFZMREx6cnZ6dG9lZVpLeTFxbVk1ZEt2cngyREJiQTYyMTBDWTJRazA3UkY0UUpvdWYyQjVFd1EKMFhRRzRnRGdLdkI5eTlKVGRQdm9zdVFuV2swa0labks4a2YzVzFWUEcvZm5XWVVDQXdFQUFhTkZNRU13RWdZRApWUjBUQVFIL0JBZ3dCZ0VCL3dJQkFUQU9CZ05WSFE4QkFmOEVCQU1DQVFZd0hRWURWUjBPQkJZRUZLazVtSW5SCnRsT0paU0F3Z0MxNFdoK0k2YkE3TUEwR0NTcUdTSWIzRFFFQkN3VUFBNElDQVFDdDZYSVNid2xzWDU2VG5DOHoKUG9RangxRzUwaHBzS2xkbnEzL1pPTk9DbjZqdkkvOTlzZDQzZTFPTzRCVlhRSHNZNlIwLzlmdnQ5VnpXQ0RXZQpoRkxwbWVJdVprZ1J4REFjdFJONmh3c1N4ZzBhWjY2alAvVE5pNnNsVU1qbEVYYXYzNmhvckt2dVVZQ09KSm9KCnlhM1Frd0xPZk85S2dPM1l3NE5OMkswTmdSWmdhNit2NitTUm9XOTVna2c1R2grclNwc2dNN05mVEgxZkVGNmgKNUorSUF5eDZwMStBT01WSFNZaHNzdlRneGEzTG9JUmlzd1ZYbXFUdGdQdTFoem5lVzNTVWtqNjNYcmgzcnBhMwp2YjlncTdwNmkwSjljZWxlbHo0elh6akhFWWQxTXh0QVIzTEg4YVlERGJUT0o4a1JDOFYvdVhSVUVqSDVVeGpaClNvdko5RVpmdkpYUG82ZGxBMHJXSnkwTTdvUC9Nb3F4QjFMYkFoOVozSnkvMFo2R3dFbEh0SlVnY3ZiZndWS2gKVG5CZG5XYnl3Y2pnRUVGMGU0YWJSOWFVNXZEcWIvMWtGd2VtM2szRzF0VFgxNngxam9LUURqaHI0cmRETjZuVgpBWkc3S2VJQlJ2VGlxRjB0cHZZV3IvMHdzdE9UdlN1OSszem9Wa3RSN1dHd3RzazFRY2NFcmc5cWU2NVd4R0F2CllERjNyeGFYSGkxTlVoOW1EK2VDNUZtZ3Y3RjdMOEt3NkN6QzRtbFY2S0hzZml2OTcweXB4OUkwUnM0MHNSc1YKbmJIMlNScFRwQlJsNjg1OC92SkxVV21SRjdHWHp3c1BOd3BZQWtIcUhnWEpaaFZTZ21iL1NVazQvYlpVdzJBWApuS05RbWdUd2JoRExBdm5VQmExQVZWdEI0UT09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KIwojIE93bmVyOiBDTj1zYWxlc2ZvcmNlLmNvbSBJbnRlcm5hbCBSb290IENBIDIgU2VjdXJpdHksIE89InNhbGVzZm9yY2UuY29tLCBpbmMuIiwgTD1TYW4gRnJhbmNpc2NvLCBTVD1DYWxpZm9ybmlhLCBDPVVTCiMgSXNzdWVyOiBDTj1zYWxlc2ZvcmNlLmNvbSBJbnRlcm5hbCBSb290IENBIDIgU2VjdXJpdHksIE89InNhbGVzZm9yY2UuY29tLCBpbmMuIiwgTD1TYW4gRnJhbmNpc2NvLCBTVD1DYWxpZm9ybmlhLCBDPVVTCiMgU2VyaWFsIG51bWJlcjogMjhiMTk0ODBhYTQ2ODFkYWM3NjA2MWY4MDJmOWFkZjk0ZTNiNzUyNQojIFZhbGlkIGZyb206IE1vbiBKdWwgMjQgMTM6MTY6MzcgUERUIDIwMTcgdW50aWw6IFRodSBKdWwgMjIgMTM6MTY6MzcgUERUIDIwMjcKIwotLS0tLUJFR0lOIENFUlRJRklDQVRFLS0tLS0KTUlJRjhUQ0NBOW1nQXdJQkFnSVVLTEdVZ0twR2dkckhZR0g0QXZtdCtVNDdkU1V3RFFZSktvWklodmNOQVFFTApCUUF3Z1k0eEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFICkRBMVRZVzRnUm5KaGJtTnBjMk52TVIwd0d3WURWUVFLREJSellXeGxjMlp2Y21ObExtTnZiU3dnYVc1akxqRXoKTURFR0ExVUVBd3dxYzJGc1pYTm1iM0pqWlM1amIyMGdTVzUwWlhKdVlXd2dVbTl2ZENCRFFTQXlJRk5sWTNWeQphWFI1TUI0WERURTNNRGN5TkRJd01UWXpOMW9YRFRJM01EY3lNakl3TVRZek4xb3dnWTR4Q3pBSkJnTlZCQVlUCkFsVlRNUk13RVFZRFZRUUlEQXBEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIREExVFlXNGdSbkpoYm1OcGMyTnYKTVIwd0d3WURWUVFLREJSellXeGxjMlp2Y21ObExtTnZiU3dnYVc1akxqRXpNREVHQTFVRUF3d3FjMkZzWlhObQpiM0pqWlM1amIyMGdTVzUwWlhKdVlXd2dVbTl2ZENCRFFTQXlJRk5sWTNWeWFYUjVNSUlDSWpBTkJna3Foa2lHCjl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQ0FnRUE1WktBaDc5b0lQaXNPTjh4bWdtcmFWTzhHNEpDRy94VXJxRzkKeVFYUThKL2g1VEhYR1ZzeUQwZmp1Q3BNVTNBeWowZUZzQ1JKN1VxTk9GWXFsbDB6V2FweGFvaC9PbzE2S2V5bQpBS25MVEFMWk5xZ01aR1dqM2YzWFZGcG51MDB2bmhJM1JpR3I4SENyNXBJWmkxWGduZUZ4bjdUYzhPa01wMzBJCnBXQnBrUlJDbzhxenVkblY1Uzk0bng1a0ZsUGlid2NZelZjMGxndUdGWTBIS3hxK2lMVXgwNDZCaVBKSEZPWEEKeWZOUFI0ZkFnVjFSOVJMbThvU3g5MnNpOU01ekdXU1RUaThYbXphaTRxUEc1WFJMTDRGTGRqY1JWQ0tjdlJVUgpOSThCbTF1RkJuZTc3R2htWGRGWkJRanI2WkcvdUNZUUdtaVhFK1ZiL0NWcXFRMVQ1L296U2J4SVExN0gwcDk1CmtpWmVCNjMrVVBqR214eEpJQWVGckovZzg4NjlQeVRaakhxUFZtR0M4RXFyOUxJK2RBY0lEZXBuUHBaT3EvcmYKRXpZWmpqcElhTFMyTVRsZjdmTVQ1YjdKSWRXeEROOHVkZ3pqbXFMRmRodUVod3duWFBiS2piajl4ZU1JNG9Obgp3RzZhTTJTaEVWRExxcVpxUU85S0hxS2R4YWtRNi9rdjR0K2tnei93b05mWkVEUm1IQnliTSs2d2w0a0NnVWRaCnFjS3BsdGQzVHNYeEZCOGtrR2V2WU9GRGhURVRiYXZuMDA4UmUyTjdkV1lXd08zbVZBbExoMEhGMVMxTnJzNUsKV0tQbk4rMWwvanE0T1N2b1l4dFdDTVJ0QTR2UjJsSThBRWZlTFBYUHhCNTJzNXFOeUZDb0o5bzZwU1JkbVpFcApyUUNzU1VjQ0F3RUFBYU5GTUVNd0VnWURWUjBUQVFIL0JBZ3dCZ0VCL3dJQkF6QU9CZ05WSFE4QkFmOEVCQU1DCkFRWXdIUVlEVlIwT0JCWUVGT0xCOGZPcU5hUXhvcXgvU1owejhXb2hGdGVNTUEwR0NTcUdTSWIzRFFFQkN3VUEKQTRJQ0FRQjZOT0lhVmE3VitqMmpyampRV2RZaVFLWE8rOVZ2MmZkR2Vpck9WNmJZa3BjdU5pT0kzRCtyRUQySApITjRMUFpJT1RONFpBeWZEMlNMZmE1cXcvZGl4c2dnN0RvaDBPRWhrUHRWM0p1NlhDbGtOWmVYM3NrZVkrRXdrCm56WXIyVStoanVKZzFGNTVzUW9POGcrLzRlUDlYUkZzWjVxekYwL09SbktkaGtjcXNEZmxabTVIQlZUbGhTRkEKbXpHVTVPR3RnaGNqTzY2VFJzVFpJNWpqa1NUNUs5RnR3SXhpdmFHQWJLWXA4bHpBWGJ2eC9RMmR1V1kyUm1wZApoWTNwSno4bmFYMlFydVRFMDdlVktJdVpISitnMFN6dlVBTW9CU0FkTU1VZ2JielZxa3ZyT0g0Z01CUHdPbDIwCmZCZTAwZTF3TUJSQkdLN0FxSnU2Qmx3cm5ZNlNJa0trSm9UNy8xTmJHV2ZsZC8wSTU2MDdWdkR6T2hzaGFKRVgKWHk1eVpJN2VNcXFnMkRrTkdhSWQ3akx2MjhlR3pnRW5aQklWczBqN2J4N1M0TEoxNnNxb1dXK2FaY1Q2SUlSeApkYkZzV0ZaM012RHlUd3cxSGhieVZWcnVpc0JCdUhVaGdZdVZuUXJ3NEE2d3dVRGgzRUJNTjZVY2NWU3NPOXQwCmVYSW00VUVSRWFZQmZyMCsvdWQwanVWdnQvVStaV3Y1RlozYldtWmtVcTFmUzBLZzFXQzlsUGtvckNsdWxkZncKUmF5ZVNWZXVRUHAzbHhyVmRPaHV1L0IrSHhwWGdUWWxhRC9Ec3pWUHVJaVl5OE02bjFTekpoNm1vMEZTY0htZQp4R2dkdXA3OFhYNEhLaktBWjJFamFVSkxDN1ZJN3ptVFIxUUtadmVHZU5rdzdvS3lzZz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KIwojIE93bmVyOiBDTj1zYWxlc2ZvcmNlLmNvbSBJbnRlcm5hbCBSb290IENBIDIgSW5mcmEsIE89InNhbGVzZm9yY2UuY29tLCBpbmMuIiwgTD1TYW4gRnJhbmNpc2NvLCBTVD1DYWxpZm9ybmlhLCBDPVVTCiMgSXNzdWVyOiBDTj1zYWxlc2ZvcmNlLmNvbSBJbnRlcm5hbCBSb290IENBIDIgSW5mcmEsIE89InNhbGVzZm9yY2UuY29tLCBpbmMuIiwgTD1TYW4gRnJhbmNpc2NvLCBTVD1DYWxpZm9ybmlhLCBDPVVTCiMgU2VyaWFsIG51bWJlcjogN2UxZTNhODhlNzI5MTU1NjE0ZjM3ZWM0OTEyYzYzMzQwMDFkZjc0MQojIFZhbGlkIGZyb206IE1vbiBKdWwgMjQgMTM6MjA6MTYgUERUIDIwMTcgdW50aWw6IFRodSBKdWwgMjIgMTM6MjA6MTYgUERUIDIwMjcKIwotLS0tLUJFR0lOIENFUlRJRklDQVRFLS0tLS0KTUlJRjZ6Q0NBOU9nQXdJQkFnSVVmaDQ2aU9jcEZWWVU4MzdFa1N4ak5BQWQ5MEV3RFFZSktvWklodmNOQVFFTApCUUF3Z1lzeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlEQXBEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFICkRBMVRZVzRnUm5KaGJtTnBjMk52TVIwd0d3WURWUVFLREJSellXeGxjMlp2Y21ObExtTnZiU3dnYVc1akxqRXcKTUM0R0ExVUVBd3duYzJGc1pYTm1iM0pqWlM1amIyMGdTVzUwWlhKdVlXd2dVbTl2ZENCRFFTQXlJRWx1Wm5KaApNQjRYRFRFM01EY3lOREl3TWpBeE5sb1hEVEkzTURjeU1qSXdNakF4Tmxvd2dZc3hDekFKQmdOVkJBWVRBbFZUCk1STXdFUVlEVlFRSURBcERZV3hwWm05eWJtbGhNUll3RkFZRFZRUUhEQTFUWVc0Z1JuSmhibU5wYzJOdk1SMHcKR3dZRFZRUUtEQlJ6WVd4bGMyWnZjbU5sTG1OdmJTd2dhVzVqTGpFd01DNEdBMVVFQXd3bmMyRnNaWE5tYjNKagpaUzVqYjIwZ1NXNTBaWEp1WVd3Z1VtOXZkQ0JEUVNBeUlFbHVabkpoTUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGCkFBT0NBZzhBTUlJQ0NnS0NBZ0VBd3Zub3hCcWdNdUs1YlFBU285RVlKdWR6OUxmNHF4R1kzUWNXRDB4MGV2TysKaUMrallkOEdSaGMzbUd0bUVta2U5ZWxZVjBaVjBkL051a2dvOTdEdjBQYmE4YTJ4WE9OUlovN1YxVHFhTzMwRApoU09LMGlGRGZyVmJTWHVqQTVqVFpHbkRZUjh5bDZ0dnpWZ21PQ1hMZ0ZYd3FySk5KUUNJaTNhUkZTRk9oR1RICmFybWVuVGw5eFRZVjF4eUhMSzdDamZoekFKNzc2cVdtU2hBOHRzWlpxRkFURW8yQm9tRjBudlhZWFV1STFuMkQKUzFNa1NOMmZzd2Fzd1BES2EycGErVHZqREg3Rk1MVjdOK3dsa1paMENwYnpjZGE1RTQzaXJ3dTRYVzdDdmI1TApXdDFyajVWV1ZkcnVlWGxyZkxPNlFRYkovZi9hQjZYVitQM3pkQnFIaUpoenIrRnA2bUpHOXErM3ptMmdIbUxuCkdQVnVqc0p0cEFaak1KRHVuTzUrRWpVMDF1NGlINHBlOFY4Nnc0YXU0N29TMVg4WllFUU53WjNibUZmbHFvclcKUXBUeW5PRUU1Tk9ja3NrL0R5bVpqRjVhbFNyQjE5Y3QyYnp1K3VjUUpEb1h2ZkVIYVo1bDhWVmk1OGFlcU9wLwpsdGUydXdtbVJwb3dRem5XMXJQUW4xRGYrV2xOK1BkOHE5aU1nenNoNlFEMFlENGp6emo4b2Y1M1hmakZiWlVTCkwzQjA3RlR5bml1TVNSc3RkQ3hMTEtOV0lWQVhNdGR0UnVZbmRZMDVJUkpadmh5ZXJsZkJoS0M1WWVaWWJMV2oKQk1RdUlTeVVncG9NbS84V2ZoMkx0cmF4eW0zUnFnem1QUTRjOHlJNGEwS1l2WWlnVWZtY3c3cGpVeVdXN0JNQwpBd0VBQWFORk1FTXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBekFPQmdOVkhROEJBZjhFQkFNQ0FRWXdIUVlEClZSME9CQllFRkVHOFNhcC94eXBYWnZvelpkMjREWWdacFJBZE1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQ0FRQ3kKS0UremFkSmdSc2VHOUtGb2IyK3FuZWVDVW9ZMDY1Q3dRVGRBRnZCYk1rOWFrUHhCa3VwUVNCZmtucndibWx2WAp4enBZVUt5MVAyZlFoR1RaSlpHTE5teUFrdVJpRUNHOVFPanVCa0VCVGl0aVh6bTMxVkhlMExPd3oyOHpKMGllCkpOOVlFQ1VsZDR3eGt3Yk1URGE0bGl4NTZYdk50ZE8rYUxJYy9QdmhGOUlZSDRtNDNuTkIxS3A2YUVYQUNDWXoKR3FiemNhQmlNR2dOdWwrR05VNld0R0hzbFJXOGZzZ1dSMW9uYThKdzJMTlFKTlppL2ROY1IzczM5VkZXdmlBbwo5US90MTJDLzJzUU04dXgrSHpHZ0dZUm8zVmd5WHJGZFZPTC9XV3RHS2FPQ1ZRb21pU2dqK1I3WkNJZjZTRlp0CkRTNHBXNnZrdFZlQnpzeUF0eGdJMUd0TmMxUjRmNGU5MDB6d2hTclVFSEZzTnBZNFVtanVGSWVBVnRmV1B1VnIKQlJzR1dvbHNTNnExTCsxM3MycVdXcUc2QVBvRFA3bFduMHFYc1JmZXFkV0FzQlhXU1BWeG1CUmNqdkE4Wk1LcwpHRE9JdWdTUDVLRDlvSFZEUHo0aVFudGpNQkp0bStFUzViVHJGaEJzL3c5YnNVQndacEM5Nno5MXNvTGFReHpmCmM5MXI2N0VodmNwU0FFS01GTzkzT2pUdjM4eW51T0V4dU0zN0xTNW1OY0IzcWkxRzFETmErV2RhOFU4N2x4aEMKT2JXTmVRSXJNMmNaMkVKTEV3U1VsdDRITldwUWxabkhZY0dyTVh0ZTF4SngrbUhEY2dpT2FGRlhCN3htUXRzdgo3L2gyNDV1T2R2MlRTWmpCWDFUL3RlOE0xWDdEVDJPTVpQVXE1R0tJb0E9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==",
      },
      rules: [
        {
          apiGroups: [
            "apps",
            "",
          ],
          apiVersions: [
            "v1",
          ],
          operations: [
            "CREATE",
          ],
          resources: [
            "pods",
          ],
        },
      ],
      failurePolicy: "Ignore",  // TODO: Set to "Fail" when the code/configs are stable
      namespaceSelector: {
        matchLabels: {
          "electron-opa-injection": "enabled",
        },
      },
    },
  ],
} else "SKIP"
