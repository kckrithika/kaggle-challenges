local flowsnakeconfig = import "flowsnake_config.jsonnet";
if flowsnakeconfig.is_minikube then
{
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
        name: "flowsnake-tls",
        namespace: "flowsnake",
    },
    type: "Opaque",
    data: {
        "tls.crt": "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURuVENDQW9XZ0F3SUJBZ0lFVVg5c1BEQU5CZ2txaGtpRzl3MEJBUXNGQURBaE1SOHdIUVlEVlFRRERCWlQKUmtSRElFbHVkR1Z5YldWa2FXRjBaU0JEUVNBeU1CNFhEVEU0TURJeU1URTRNVGd4T1ZvWERUSXhNREl3TlRFNApORGd4T1Zvd1BERVNNQkFHQTFVRUF3d0pabXh2ZDNOdVlXdGxNU1l3SkFZRFZRUUxEQjFUWVd4bGMyWnZjbU5sCklFUmxka1I1Ym1GdGFXTkxaWGxUZEc5eVpUQ0NBU0l3RFFZSktvWklodmNOQVFFQkJRQURnZ0VQQURDQ0FRb0MKZ2dFQkFMa2s2a21OU2pqT1lIZlNxN0lJL0lSWGU5WndZM25ZODZxbVJzK3lMZXpsUmJvdHVXWmZ1MzVIVEc3UgpJdVZtUW9LVGROcFUzQ0dCMjlFRG9pSHBaNy9XTUxpN2R5eHVtR1ZlNGpQbjNZYUdxajNla29xSXlubm44WFhWCk5WbFhpemdJQXhHcUsrb2tQOXcyQ0pYeVZDOWtIU2ZBOHIyUW1rTjNERDN3NkIxTjYrcUtyVUV6V2cvY3ordjQKcThHWHZxWUp1OWkwaThrTFFZUE1UdlorUnRhc0JrbGd1RkVGeFkvSHFXbGlJVzFOdVRGaUpNdWdKcG91d0pxYgo4SkVqMDJYRm9pQzF3WmNEZ3FzYkF4a3lGb2JlcEpsUFZOTXpoVUhtWVI4WTIvZHJTV1F5VlBPaUVMVUV2QjBjCkJUWWpwbUpoMkJkSXRONjhCU3ZtUktWekZqTUNBd0VBQWFPQndUQ0J2akFkQmdOVkhRNEVGZ1FVMGVKN0VkVGMKM2pMNStVVnRUcjEwam1PbWFDRXdUUVlEVlIwakJFWXdSSUFVanNlK0x5Ym42M1lnWTFxQzFhVlczSHcyTkFDaApKYVFqTUNFeEh6QWRCZ05WQkFNTUZsTkdSRU1nU1c1MFpYSnRaV1JwWVhSbElFTkJJREdDQlFDSGRDa0FNQTRHCkExVWREd0VCL3dRRUF3SUZvREFnQmdOVkhTVUJBZjhFRmpBVUJnZ3JCZ0VGQlFjREFRWUlLd1lCQlFVSEF3VXcKSEFZRFZSMFJBUUgvQkJJd0VJY0VDZ01sMFlJSWJXbHVhV3QxWW1Vd0RRWUpLb1pJaHZjTkFRRUxCUUFEZ2dFQgpBRUVkSCtDWDF2dzQwZ1VVMlNiY2Znd296YTlqWjFtb3BGckREbDBIK0l3dyt0cVNQSFJjNTU0NXRYVXJ5K0luCnlzZVpBZXpsdDFpUzI4eDQ2dTlhQkVVTCtEMUd0Y0RSTEVaWEdiQUQwZWFGS3hMc1lEV1dJcmNNZy84cmhqSFIKZ1NMMlp0MWNjMm9FeXRoWlVvTjhhMU9jNDN2cUFBemx6emFCVm9YdzVoNFVlcFpVbEFRSWphYXlmTEpSNkRvcQpQeXRsK2ZiY3BBczBXdnNYM0NMSEEyL2x3NEpiSUpDUmpTVzhXUHczMzdFOFZTN2lXSktHSk9oM0pTNWxPOTRuCjhveHczZDd4dDZ1RzVPL3FvWnZrOGFvVC9jejV6c2UyM2w0UzFvZmpMS1J2RmliMEpRbUhKUDZ2elZSV3QrSnEKWDl4RlU3cGZwTDMvaHRhRVA0NXlmbFk9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURxakNDQXBLZ0F3SUJBZ0lGQUlkMEtRQXdEUVlKS29aSWh2Y05BUUVMQlFBd0lURWZNQjBHQTFVRUF3d1cKVTBaRVF5QkpiblJsY20xbFpHbGhkR1VnUTBFZ01UQWVGdzB4T0RBeU1qRXhPREU0TVRsYUZ3MHlNVEF5TURVeApPRFE0TVRsYU1DRXhIekFkQmdOVkJBTU1GbE5HUkVNZ1NXNTBaWEp0WldScFlYUmxJRU5CSURJd2dnRWlNQTBHCkNTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDVUJzOWR0RnVPbFhoWVFMc2wyYVhtTldLcDM2TzYKQU9Fdy9aSzEyV2REcTBxTmVYVDlreFFjaGxJRXgvNUFHM1hLRndFWFVnRmpzQVNVdVUrYWFOUWU2U1dkRUtnNwo0NXlqeW5OMkMyMEFZTTMvc0swQUlkN2dXdzNMY1lHaCtRbVhJeXpsMHBSRUV3SVJLOXB2aGdISE5UcDlDVzNoCkhHTENPMVdtOVo3aitaVDA2akVNWlRVYWNUOEVxU2FuNk93dG1NWkU0bVVHdlVlTTBqS3dCT1IwcWFJTG1FOTYKSmZWZHVuR3J5YTEvUVFRQ0pyNlVMQ3M2b2gyRmhibWVqbkppYlpNNCsyYjFVOXBDR3ZKWFcxZ0hBSzRQV3FubQp4K1lDazVTdlNPQjFtd21oVFlYc29SQ1k3VWhDblVaK21EcFVBczNGSkFNa1VEcWJlNG1jTXh0VEFnTUJBQUdqCmdlZ3dnZVV3SFFZRFZSME9CQllFRkk3SHZpOG01K3QySUdOYWd0V2xWdHg4TmpRQU1JR2ZCZ05WSFNNRWdaY3cKZ1pTQUZOSzZsL1BFL21oOFIzTng3ZUE2dWdvZlZLUW9vWGFrZERCeU1Rc3dDUVlEVlFRR0V3SlZVekVUTUJFRwpBMVVFQ0JNS1EyRnNhV1p2Y201cFlURVdNQlFHQTFVRUJ4TU5VMkZ1SUVaeVlXNWphWE5qYnpFV01CUUdBMVVFCkNoTU5SbWxoZWlCRFFTd2dTVzVqTGpFZU1Cd0dBMVVFQXhNVlUwWkVReUJKYm5SbGNtNWhiQ0JTYjI5MElFTkIKZ2dSNGRxaytNQTRHQTFVZER3RUIvd1FFQXdJQkJqQVNCZ05WSFJNQkFmOEVDREFHQVFIL0FnRUFNQTBHQ1NxRwpTSWIzRFFFQkN3VUFBNElCQVFDbFpnaFNwYXRPQWtWcmJZYU9hSU1SVnJpYjZ6MWo4OVdJbEVMMmg1U2dWcTRPCkxzSWtaUytOaEs3eFp4ak9ZQW0rVEVxeEZmMytieEhmenRsZ0RtWnlISzJ3aDdaYS9xVnh0QS9BZ0FoNEIvL2IKY0ZaMkw4ZFdlL0Jrd0V3MXdsc1BHZGhnQUQrTHowZWdTWElNU3RwSDZqa1pwWXJvRVNJNGhrdnlHbGEwZVhsYwpNQjJRR2NLNHNuNlZIYk56eTlLNXdlM2JtWnhlb0t0YVFPSzhJOUwxZU1zelNQaTBjT3IvMXBkdktwclVlTVZzCm1MNmpwVk1ZZVdFSlR5ZDNjVmpiWEFaN0ZieVFkOWc5QnkvcUMyaUcwV2ZFL01QaWtpeWs0aEVsbE9TKzl3Q24KQXZoRHpwT3g5cFF4MmNZV3BzL1BGcXV6VXpOanNIanlBNWVCOTFvcwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlFQ2pDQ0F2S2dBd0lCQWdJRWVIYXBQakFOQmdrcWhraUc5dzBCQVFzRkFEQnlNUXN3Q1FZRFZRUUdFd0pWClV6RVRNQkVHQTFVRUNCTUtRMkZzYVdadmNtNXBZVEVXTUJRR0ExVUVCeE1OVTJGdUlFWnlZVzVqYVhOamJ6RVcKTUJRR0ExVUVDaE1OUm1saGVpQkRRU3dnU1c1akxqRWVNQndHQTFVRUF4TVZVMFpFUXlCSmJuUmxjbTVoYkNCUwpiMjkwSUVOQk1CNFhEVEU0TURJeU1URTRNVGd4T1ZvWERUSXhNREl3TlRFNE5EZ3hPVm93SVRFZk1CMEdBMVVFCkF3d1dVMFpFUXlCSmJuUmxjbTFsWkdsaGRHVWdRMEVnTVRDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVAKQURDQ0FRb0NnZ0VCQUsyRyt4c1NOQlVmdUFqanowenBqbWNDSWNLUDFyQlNHdWgzK25WM0d1enZtcTQrb25aSQpPVVhlWmgrT1lGdEJzQXhKNVRnYUZjWWZRc0psR2ZMY0pjTjdLR1FrWDhjWllBVVhFY0lRcE5ORGZpdUpaUDl4CmIvTWJ1aUg5ZnRWNWkrVmsyelA0ZXpiSDZWM0czcE5QYXZ6enI4QVk4azZuVmpDZkNIQVVuL2w1Zmh6dk9CeGQKSjF0WmQzRnA4UWE4QktzUUFMMWY0ZmlsM2g1Ymx3WDVFTjZML1NzRnoySFo3TmliZmY0T0ZsL3Fmd09pbkJFdgo4NGVjQkFIdjQ1TElvaXZrV2s1VVlsTytoUkduS1NTWXJaZ0w4RzlCaWsyR3BzTUhCZUhYcXVyQUo5b0xXaWRsCktTbVhJUDNmcjRKNzFXUWFLN2srVlh0c2o0Uy81K1Z4WUgwQ0F3RUFBYU9CK0RDQjlUQWRCZ05WSFE0RUZnUVUKMHJxWDg4VCthSHhIYzNIdDREcTZDaDlVcENnd2dhOEdBMVVkSXdTQnB6Q0JwSUFVQlJCcTRRRWYwWU1BYXhJMQpUSGEzWGl2ejNFaWhkcVIwTUhJeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoCk1SWXdGQVlEVlFRSEV3MVRZVzRnUm5KaGJtTnBjMk52TVJZd0ZBWURWUVFLRXcxR2FXRjZJRU5CTENCSmJtTXUKTVI0d0hBWURWUVFERXhWVFJrUkRJRWx1ZEdWeWJtRnNJRkp2YjNRZ1EwR0NGRUVVNm54ZGJNQjNubGZDdVh3UwpvWlFQTDV0Nk1BNEdBMVVkRHdFQi93UUVBd0lCQmpBU0JnTlZIUk1CQWY4RUNEQUdBUUgvQWdFQk1BMEdDU3FHClNJYjNEUUVCQ3dVQUE0SUJBUUNUcFpRTko0aVFaeUlHTEltSVpMTDJvTnZ5dnYzY2dpd3pnakhvN1VHSFdodzMKa2NpWFlNbmR4OHdDZHdxdno3MXNjZjFUMkNUM01XTVRaN29CLzFCNkNEWEswNk9QNXhaQ2xBb0ZwTk9uVHl3NQpQWDJIZENFUC8yZ3I1ZHZWVDB3RmVHZEhlcGVjcExNWjlXWkZRZWpoZXRsTXBFclVvUU14d3V6K1hYY0ZmMTQ2CllGUndkNTN2Y1NzUmlGL1lvclpJd0pzS1dUZk5RWXI4QlhBdVllUTZ1dU1PeEJHL3E2Szg5WjdGcXJ1c1VCbCsKWDZmN1o1eUh4QzNyQS9YZURnc2l4d1JkQ3hlamE2dzhOTS9heTBwWnltamRLNEZnMFVpcVF6MEI5c1hGOU9NRQpNUDVzdDZKS3lwZUwxTUNVOVpka0VTMnpML3UvMHVpNkxmWnpYazlRCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K",
        "tls.key": "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JSUV2UUlCQURBTkJna3Foa2lHOXcwQkFRRUZBQVNDQktjd2dnU2pBZ0VBQW9JQkFRQzVKT3BKalVvNHptQjMKMHF1eUNQeUVWM3ZXY0dONTJQT3Fwa2JQc2kzczVVVzZMYmxtWDd0K1IweHUwU0xsWmtLQ2szVGFWTndoZ2R2UgpBNkloNldlLzFqQzR1M2NzYnBobFh1SXo1OTJHaHFvOTNwS0tpTXA1NS9GMTFUVlpWNHM0Q0FNUnFpdnFKRC9jCk5naVY4bFF2WkIwbndQSzlrSnBEZHd3OThPZ2RUZXZxaXExQk0xb1AzTS9yK0t2Qmw3Nm1DYnZZdEl2SkMwR0QKekU3MmZrYldyQVpKWUxoUkJjV1B4NmxwWWlGdFRia3hZaVRMb0NhYUxzQ2FtL0NSSTlObHhhSWd0Y0dYQTRLcgpHd01aTWhhRzNxU1pUMVRUTTRWQjVtRWZHTnYzYTBsa01sVHpvaEMxQkx3ZEhBVTJJNlppWWRnWFNMVGV2QVVyCjVrU2xjeFl6QWdNQkFBRUNnZ0VBQXNxbWlRbTEyRW5DLzV1RmE0K2lJR3dNbWN6NUJheDZtV255RmJpZ2psQUkKcjBnaTRhM0kyY2NXYjhkUjA0dityYnhaSGQrbUJXVlJYSzN3TGJzT0RaWkdYQ0FMZnlLREdXZ3hyZlJZTitxTwpPaitYRGJxeFNZbWJSTys4T0Z3a1pSUmpMaUFzUGF3TlFITkV5WW9Dc0p6b1ZFeWUvRjBTbzdqRytQb2ZHSU5UCnpqMmJ1Y3lueE40a0xKUG9PZWYxRm5rRysvZDFySEJGdjJKM1g1WjhZTGJIdldsTURPR1Uzb2xoY084T25GaXgKYTZ6bGg4ZXM0L2RLRWgzWlVic2pHSnptNk9HaGFUUzdWOGtCWUFnaVd0cmgzMmxTc21vS2V5OStrY0R6UHdaZQprQ0VxUjJKajYwU0pueTY4UmRGRWIzV1NDc3hFanB5ZEs0eHhkTUtORVFLQmdRRDV2SGV6S3F2bmt2emp3dVI0CndqMDk1bGNyTnNTNlVNcmhPczdqeWlLZFIxT3NlbGJXRXQ4Y09lTHhDLy8zc2dpS3dxUkVkRmVOSlYxU01mYWIKcTYxdVNSVHJObVQzQ2J0cVRvT2hkWXQycGZyRzNJamJpWSs4QW5OcU14UjBTaTJqOXBLWENuZW9FREZ1bmxsUgppY3lUVDFMdjVPa3RLSDFxcVFtTUZacm1Jd0tCZ1FDOXliVmdaazhWTE0ydzBpUXV1bVQvSmROdksrZGN2bTNXClNyOTZjYkhQZ1NSVmNQejd6UWpqOEtuZjlxb1YyZ1UxbDBvbWRYUmhheG1IUXFDT055cHllYjBPdFZPRm83MTcKZmprS1BQamRNWWNQeWw1alA3REVPVWZ2MGRpMWsxajBjWW1IYzNaKzF1RWw3ajBxUkxRWmxDaGhwWEtRMm9NNQo0WHBuZ2hHb3NRS0JnQkpIamtkcC95MHpJQm1Yd1Z0cGRFd2NtUkxMcm5pb3cwRGJLaHVZUnhKV0R6VFh1NVZ0CnlqRHB0OGZIQmhSZVRxdkJkWDZoT1d0V2FjOURZdmFnQ1ZEQ1BxcTh6NFVaakVOS3ZlM0tpY3ZFZUdlbjZzaU8KK0J0ZDNvN09jRmZXdWlKL1FObVhaWXpDcXF1YklaU0xUcE1Wd2s5VzVRNXVJVWYyV1lHTWIwc2JBb0dBZDNuSQo1ZVBpT3hsV2I4OEttaVFiT29oc2YxcnJMblp2SE8wM2QzU2xsRlRmTTY2S2hGWENHQVRFWEVxakxsaHUyUnJoCndpNUUwcU1pa2dUK29DallYdktHY3dEeGtIclE2VEkvNUZNWDg5K2UvL0RNMUx3ZW9walEwWWVRWGxaaE5KbFoKRTkwN0pvUk5mcHhwQXZmM1RQYjVLT2VIcE9yNm0zQjNwenU1dERFQ2dZRUF2YnZUYjNuSDhEVXNIbG9qaDJoTwppOVU1NDlzRGdmR1YyL0tLMEM3QnFsMkRmRmFtRUFvRkJYbWszU21oRW5VTVFROEdQMTNnYzJnc0NSSGlpWGdpClZJTFAza3VBVEJzenhYZFduSklXVU1pOG1iQkNMb0VNK2x1YnJrZ3lzemNwcnhYWDM5U0YwQmNxb1ZIbEJSMVUKQ3dYYTBUb3cxaGdRUzcyQTZ6bnVEUFE9Ci0tLS0tRU5EIFBSSVZBVEUgS0VZLS0tLS0K",
    },
} else "SKIP"
