local mcpIstioConfig = (import "service-mesh/istio-config.jsonnet");
local istioPhases = (import "service-mesh/istio-phases.jsonnet");

if (istioPhases.phaseNum == 1) then
{
  apiVersion: "admissionregistration.k8s.io/v1beta1",
  kind: "ValidatingWebhookConfiguration",
  metadata: {
    name: "istio-routing-webhook",
    namespace: "mesh-control-plane",
    annotations: {
      "manifestctl.sam.data.sfdc.net/swagger": "disable",
    },
  },
  webhooks: [
    {
      name: "istio-routing-webhook.sfdc.internal",
      clientConfig: {
        service: {
          name: "istio-routing-webhook",
          namespace: "mesh-control-plane",
          path: "/validate",
        },
        caBundle: "IwojIFRISVMgRklMRSBJUyBGT1IgREVWIEFORCBURVNUIE9OTFkKIyAKIyBOT1RFOiBETyBOT1QgTEVBVkUgQU4gRU1QVFkgTElORSBBVCBUSEUgRU5EIE9GIFRISVMgRklMRQojIAojIFVzZToga2V5dG9vbCAtcHJpbnRjZXJ0IC12IC1maWxlIGNhY2VydHMucGVtCiMKIyBPd25lcjogQ049U0ZEQyBTZWN1cml0eSBSb290IENBLCBPPSJGaWF6IENBLCBJbmMuIiwgTD1TYW4gRnJhbmNpc2NvLCBTVD1DYWxpZm9ybmlhLCBDPVVTCiMgSXNzdWVyOiBDTj1TRkRDIFNlY3VyaXR5IFJvb3QgQ0EsIE89IkZpYXogQ0EsIEluYy4iLCBMPVNhbiBGcmFuY2lzY28sIFNUPUNhbGlmb3JuaWEsIEM9VVMKIyBTZXJpYWwgbnVtYmVyOiA1MDk3ZDAwYWY5MmQwMDBhMTAyNTUwNGI5NTYxZjcwMmJkNzNiNzhkCiMgVmFsaWQgZnJvbTogVHVlIE1heSAzMSAxMzozMzowMCBQRFQgMjAxNiB1bnRpbDogRnJpIE1heSAyOSAxMzozMzowMCBQRFQgMjAyNgojCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlEMkRDQ0FzQ2dBd0lCQWdJVVVKZlFDdmt0QUFvUUpWQkxsV0gzQXIxenQ0MHdEUVlKS29aSWh2Y05BUUVMCkJRQXdjakVMTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1QKRFZOaGJpQkdjbUZ1WTJselkyOHhGakFVQmdOVkJBb1REVVpwWVhvZ1EwRXNJRWx1WXk0eEhqQWNCZ05WQkFNVApGVk5HUkVNZ1UyVmpkWEpwZEhrZ1VtOXZkQ0JEUVRBZUZ3MHhOakExTXpFeU1ETXpNREJhRncweU5qQTFNamt5Ck1ETXpNREJhTUhJeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWUQKVlFRSEV3MVRZVzRnUm5KaGJtTnBjMk52TVJZd0ZBWURWUVFLRXcxR2FXRjZJRU5CTENCSmJtTXVNUjR3SEFZRApWUVFERXhWVFJrUkRJRk5sWTNWeWFYUjVJRkp2YjNRZ1EwRXdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCCkR3QXdnZ0VLQW9JQkFRQ3hpM0FaSFpSbkRlM0liWVdxSE5MT0VBRTQzdExZWDE4aS8rZTRIY2VvSVZiRStWU1YKa2w0bUpXRHpLTXhORFVnR3RBN2JNaytyRUJaaGhkYWllcGcxODdvN2w3NTR0NWx5bkhJOFFTeE1MOHpiKzU2SQp1UVRnOXUreE1iMUZRTUFqaVQxZ1BOU01KNy85d2tQdDBZV09hdWQyYXFVdllseXJndHZaVnFnamtwMktVUzR4CjVpTjh3ZGpvcUFLZ2Z3Nk1aR1pFMCs1RklqSmRWMWZvN1lyMVdZZ2lLNlZPUFhLd1FUWkRqL2tXbmZNc3Q2b0YKUml0VjZ6REtwN01neVUrWnVISGlxK2h5cFc1cEtEb1FvcFl0ZFRJLzNnYW03VjVqR0szdHEySFprTnVvd0dsVgpyYWdDQlNieXpPTWhSM1JpVEpUUUljcVV0YTVlaVBJMll3My9BZ01CQUFHalpqQmtNQTRHQTFVZER3RUIvd1FFCkF3SUJCakFTQmdOVkhSTUJBZjhFQ0RBR0FRSC9BZ0VDTUIwR0ExVWREZ1FXQkJTdm0wMkpnRmJ2UDFMRHl6eWUKd2RCUXA1VktXekFmQmdOVkhTTUVHREFXZ0JTdm0wMkpnRmJ2UDFMRHl6eWV3ZEJRcDVWS1d6QU5CZ2txaGtpRwo5dzBCQVFzRkFBT0NBUUVBUTkyOElMNFo1RC9QSDZUajZLeHZrWmJ2V0NhQVVGU25HUzg4b1NXb1hKMUJYQXhWCjgxNVVIMkluNnRDZUJkYjVzc3BvVm9VVzI2dnpiUVUreE5oaDhCU1ZvUzNZTTdtY2V2M1ozTmtQcEczUnhNUkIKL3E5NElyc0ZaRytVSERPT0xlSFF6Q3NhVnJrTElnN1F3U3BDaTQ2Yjh5MWNTc1UwQVBuc1RXWEtJdVVRSW1oMwpXTVRWaTJsNGxtYTFVZ1U2cHQ1amphbUpmdEE3T01UdzBmVkZJWkt4RWxaYjkxZ25sNGlPWFFzSFhvcld4QTh3CnFXVjJ5ak5KSUZTZkdSeGVCSjQyMlJnK3ppY1VLNzFOejFhUHRqYWZBMk5sZTg3NVNQTkc4VGUxOTIyNXdKY1IKNXI0aFI3K2JsQnNiTGIrK2lmbVRnSFZpUndFcHVuQVZOczNlNUE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCiMKIyBPd25lcjogQ049U0ZEQyBJbnRlcm5hbCBSb290IENBLCBPPSJGaWF6IENBLCBJbmMuIiwgTD1TYW4gRnJhbmNpc2NvLCBTVD1DYWxpZm9ybmlhLCBDPVVTCiMgSXNzdWVyOiBDTj1TRkRDIEludGVybmFsIFJvb3QgQ0EsIE89IkZpYXogQ0EsIEluYy4iLCBMPVNhbiBGcmFuY2lzY28sIFNUPUNhbGlmb3JuaWEsIEM9VVMKIyBTZXJpYWwgbnVtYmVyOiA0MTE0ZWE3YzVkNmNjMDc3OWU1N2MyYjk3YzEyYTE5NDBmMmY5YjdhCiMgVmFsaWQgZnJvbTogV2VkIE1heSAwNCAxOTozMjowMCBQRFQgMjAxNiB1bnRpbDogU2F0IE1heSAwMiAxOTozMjowMCBQRFQgMjAyNgojCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlEMkRDQ0FzQ2dBd0lCQWdJVVFSVHFmRjFzd0hlZVY4SzVmQktobEE4dm0zb3dEUVlKS29aSWh2Y05BUUVMCkJRQXdjakVMTUFrR0ExVUVCaE1DVlZNeEV6QVJCZ05WQkFnVENrTmhiR2xtYjNKdWFXRXhGakFVQmdOVkJBY1QKRFZOaGJpQkdjbUZ1WTJselkyOHhGakFVQmdOVkJBb1REVVpwWVhvZ1EwRXNJRWx1WXk0eEhqQWNCZ05WQkFNVApGVk5HUkVNZ1NXNTBaWEp1WVd3Z1VtOXZkQ0JEUVRBZUZ3MHhOakExTURVd01qTXlNREJhRncweU5qQTFNRE13Ck1qTXlNREJhTUhJeEN6QUpCZ05WQkFZVEFsVlRNUk13RVFZRFZRUUlFd3BEWVd4cFptOXlibWxoTVJZd0ZBWUQKVlFRSEV3MVRZVzRnUm5KaGJtTnBjMk52TVJZd0ZBWURWUVFLRXcxR2FXRjZJRU5CTENCSmJtTXVNUjR3SEFZRApWUVFERXhWVFJrUkRJRWx1ZEdWeWJtRnNJRkp2YjNRZ1EwRXdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCCkR3QXdnZ0VLQW9JQkFRQ2NJQkRqNkVTKytFMk5KKzJkZlF3Q3FkZTlhSVZYSE9yNnRUOVl0RlNHVVFhdUI1ZzUKellkWXZIZ0poYW8yc0xvdnBBY0NOUm53RU5MdDNaOUVNa2liUU5keWo0bHRPV0VxQU8wM3czNU1SMXc5QzM0eQpuQmROeDFLajRSU1hZWEtGVjlYZWJGQXR2d005bkxBYXBEQ2FnUEJkVDVWWEdpTUJmblBrNXBMenUwOXRFaXl6CituKy9laks1bUhITXltM0s5VHQzVzNCNnk5dUxnOXNOT3NNSG45T3oxSVJYbE45VHd1TEt5cWpsMWY1ajBDUGYKNDBOY2JoSTNVekQrL2RFZlJxS3hUWG91Q0FFeWhhdFNhK1d6OEJLWDdVZG5TTFArd3lLUms0UmRHb0Qwd0FBTQpRM1hNZUk1MkpVUE05Z1ByRytRcVdibitXazRCL0cxRWE0akxBZ01CQUFHalpqQmtNQTRHQTFVZER3RUIvd1FFCkF3SUJCakFTQmdOVkhSTUJBZjhFQ0RBR0FRSC9BZ0VDTUIwR0ExVWREZ1FXQkJRRkVHcmhBUi9SZ3dCckVqVk0KZHJkZUsvUGNTREFmQmdOVkhTTUVHREFXZ0JRRkVHcmhBUi9SZ3dCckVqVk1kcmRlSy9QY1NEQU5CZ2txaGtpRwo5dzBCQVFzRkFBT0NBUUVBamNlZjJhejA3cFdXRDBUdURvZ0VtbFRDeE0xV29XVENYMHVkQ3VKaHdhTk1aR3AyCkJwbERyaHp0S0lqbThkdWlveHpyaFVwbzQ3UEkzQUoyRnhXVlAycDh5enhOaVgwM2hIb1dINEc0dWFEd0QrYXMKemd1bWZ3TldvaHhaLzNVSEY2Qi9PaWhtWmc4b1BXQTdkcnBEVTR3TzUydWJGZzRpQnFsUzJ3NnhlMG9NcUM0VgpBa05hT0I2dE55dlloSmNtVDBDbzIzckIzNzAxNHkrbzBaNFVEOTdvY01uUWMxNHEzcFJ3dGZzaUExUlVLYmFlCjZiWS9xUDBTRzVvVkt1a2xWK1QxY1hFOUxONnJMbk9ZZkhoVVQ2czEwVTJjZE8wcldtZ0pJSjBGQmk0Y21RUGoKYTNiczkxVlEraE03ZklKaVFMV0hFRDF0Ynk0MlJnMmVEa2QwMHc9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCiMKIyBPd25lcjogQ049U2FsZXNmb3JjZS5jb20gVEVTVCBTSEEyNTYgUm9vdCBDQSwgT1U9Rk9SIFRFU1QgUFVSUE9TRVMgT05MWSwgTz0iU2FsZXNmb3JjZS5jb20sIEluYy4iLCBDPVVTCiMgSXNzdWVyOiBDTj1TYWxlc2ZvcmNlLmNvbSBURVNUIFNIQTI1NiBSb290IENBLCBPVT1GT1IgVEVTVCBQVVJQT1NFUyBPTkxZLCBPPSJTYWxlc2ZvcmNlLmNvbSwgSW5jLiIsIEM9VVMKIyBTZXJpYWwgbnVtYmVyOiA3ODI1Zjg3Y2QxOTg5ZTNhNWEzNGVjNmVmNGIxYzlhCiMgVmFsaWQgZnJvbTogV2VkIE1heSAxOCAxNzowMDowMCBQRFQgMjAxNiB1bnRpbDogTW9uIE1heSAxOCAxNjo1OTo1OSBQRFQgMjAyNgojCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlEd3pDQ0FxdWdBd0lCQWdJUUI0SmZoODBaaWVPbG8wN0c3MHNjbWpBTkJna3Foa2lHOXcwQkFRc0ZBREI2Ck1Rc3dDUVlEVlFRR0V3SlZVekVkTUJzR0ExVUVDaE1VVTJGc1pYTm1iM0pqWlM1amIyMHNJRWx1WXk0eEh6QWQKQmdOVkJBc1RGa1pQVWlCVVJWTlVJRkJWVWxCUFUwVlRJRTlPVEZreEt6QXBCZ05WQkFNVElsTmhiR1Z6Wm05eQpZMlV1WTI5dElGUkZVMVFnVTBoQk1qVTJJRkp2YjNRZ1EwRXdIaGNOTVRZd05URTVNREF3TURBd1doY05Nall3Ck5URTRNak0xT1RVNVdqQjZNUXN3Q1FZRFZRUUdFd0pWVXpFZE1Cc0dBMVVFQ2hNVVUyRnNaWE5tYjNKalpTNWoKYjIwc0lFbHVZeTR4SHpBZEJnTlZCQXNURmtaUFVpQlVSVk5VSUZCVlVsQlBVMFZUSUU5T1RGa3hLekFwQmdOVgpCQU1USWxOaGJHVnpabTl5WTJVdVkyOXRJRlJGVTFRZ1UwaEJNalUySUZKdmIzUWdRMEV3Z2dFaU1BMEdDU3FHClNJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUUNwRTl1Z283K0hKdlVxaWNGSEhNZmV5N0toVWhOalFaR2gKWlJJVzBwMVZyNFNKRWhkYVdXQW8yb2pzREh4c0hNaXR2UDYvSGJKcldBV3ptM3ZHV3E5N1BmNmlDaU9iRDhiNgpqSzlrRHdtS3lrQUluWnNGK1c4dURSanJjR0N1Rmg3eFVNQjlaU1FFYjFqRy9ocnBXMTI4NHVFUCtlcmo3QitaCnJYeEhOcEhUZEpGQXZJZ0ovWG4wb0RTdGFiSkdJVFc4MEN5d0FpQ3E2eGZpOWgwb1ByNUxNRGZLS2QwOXIvKzMKTllzL1p5bVZJRFVLWTE0QytNNkNmbjBYKy9lUnZWcFVPc29vMmdkRkNPcjgwak9MUFp5bjdUUUkxdFBCNDYxNgpCWEo1UitXOHZXb0NjSXhXM0tReFpnY0UvSmQxNEUveEFna3FwZDVHVFhROGEzd1JqMERaQWdNQkFBR2pSVEJECk1CSUdBMVVkRXdFQi93UUlNQVlCQWY4Q0FRRXdEZ1lEVlIwUEFRSC9CQVFEQWdFR01CMEdBMVVkRGdRV0JCUUIKSS9KUnBoOFQxQk4vdWRWaUxzN2tMdXJTSmpBTkJna3Foa2lHOXcwQkFRc0ZBQU9DQVFFQUtPaWdGdnVFME1zSwo1NEcrMEpQc0tCWC85YXZQTExTd0F0UzZNUi9ZK1o0MzFsclU0TFBXb0NHenp4QVR2ZW1vbFR6TWpSY1d2U0FlCk5RYTlteis1Y01vcXNqZWlHVDExaXdhejFOZGtNdXhXRVhoOXhhQUJ0aDRiM2pvQ3EyalN3WFJSbUFDSE1OT2EKOTJLS2d5U2haYmc1MWkxUHpEQnZvS0tWQ3VhalZZclk3VG8vd2UwOStiVCs0NkQ0dzdmNmw5TThHQ1U1SGR4ZgpUdjFnQ3c0RXM1bGFzYlBuYnBkOE1RUUZvQUNyMlVqMlRVU0ZiTGtJVXB6S1cvenZZVVp2OXN1bGd2Q1poNkQwClVONWVkNWdPcUhYN2ZIbVhXaFpWS1VRYXEyejNXWEVlejdJWFROSzQwVnBlZTNrcE8vTytGbVFFMkJZY1lYbVIKUWVxSmwxcExnZz09Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0KIwojIE93bmVyOiBDTj1zYWxlc2ZvcmNlLmNvbSBJbnRlcm5hbCBSb290IENBIDEsIE89InNhbGVzZm9yY2UuY29tLCBpbmMuIiwgQz1VUwojIElzc3VlcjogQ049c2FsZXNmb3JjZS5jb20gSW50ZXJuYWwgUm9vdCBDQSAxLCBPPSJzYWxlc2ZvcmNlLmNvbSwgaW5jLiIsIEM9VVMKIyBTZXJpYWwgbnVtYmVyOiBkYWQyOGQ4NDNmYzczMzI1ZDRjMWE3NTIwN2Q0ZTc0CiMgVmFsaWQgZnJvbTogVGh1IE1heSAyNiAxNzowMDowMCBQRFQgMjAxNiB1bnRpbDogVHVlIE1heSAyNiAxNjo1OTo1OSBQRFQgMjAyNgojCi0tLS0tQkVHSU4gQ0VSVElGSUNBVEUtLS0tLQpNSUlGZnpDQ0EyZWdBd0lCQWdJUURhMG8yRVA4Y3pKZFRCcDFJSDFPZERBTkJna3Foa2lHOXcwQkFRc0ZBREJZCk1Rc3dDUVlEVlFRR0V3SlZVekVkTUJzR0ExVUVDaE1VYzJGc1pYTm1iM0pqWlM1amIyMHNJR2x1WXk0eEtqQW8KQmdOVkJBTVRJWE5oYkdWelptOXlZMlV1WTI5dElFbHVkR1Z5Ym1Gc0lGSnZiM1FnUTBFZ01UQWVGdzB4TmpBMQpNamN3TURBd01EQmFGdzB5TmpBMU1qWXlNelU1TlRsYU1GZ3hDekFKQmdOVkJBWVRBbFZUTVIwd0d3WURWUVFLCkV4UnpZV3hsYzJadmNtTmxMbU52YlN3Z2FXNWpMakVxTUNnR0ExVUVBeE1oYzJGc1pYTm1iM0pqWlM1amIyMGcKU1c1MFpYSnVZV3dnVW05dmRDQkRRU0F4TUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQwpBZ0VBdkdNRWtmWXVtVjNnZlkvY2N1RWh4dGxzVm4yelp1OFVMM0tjS2JEMDBHbk5oRTlUU25QS296TzIwcTByCkJVVHFFbEZURUtiZ2UwYVBWV1N5QndHRmQ3WXZtWXEvRThDTjdTeW9iNEF2cEIwM2RJYzRoUkRpakgvVnBTRGQKdW81SHhLK0FMQmtxcHBRamlkZ2lzU1FtazhVMHpPbUloeittN2daM1dYb1ZhVWpHWlZ3NlUzNFdPR01lNW9BagoxSDh1VnBvZjk1Qy9LekRRWnh5Q0FSY3NHcGZTS1BBMkwvN3AwYllQTFB4ekVzSjVtd1JvRjUxNHYveFAwZnR0Ci80dDZya2REbDlxQ2RhZEdmKzJsV1lUcXY1VloxODVtenhHLzJFblBqMklRZk1lZFpBNHc0clp6MHhaSjU4UHUKdmFObTZ2Z2VTbUw2cWZRb0lsUEQyWXVWeWZXMi9mMmZCcHJIKytYQnlhSmxhbXFzRXFNS2tFbnhOTkFxbGNpcwphb0xzazFvU0EwWE1Dbm5neW5EMUdib0V0cHRvb0tWSGRaei9RNU1ZVXlxZXE0cTErTS9JN2RIRVZucE45RUgvClJxVG1RZ0FkU2xjY2IrL0FUdmgxNlN0L3BDbFhTWU5JOEN6WTlYQjRGaGVWS21RWWFRMW1mRnN5cExJaHJZa3kKc2VRQWRwRnBWY2RQUkkvRlhqcGtDYzZCYTQzSFRONndhdG9DdGpQWk40QTRyUWs2ckx3aElQMkpqSTk0RVdZTwplNmlhT29Qb1BWTERMenJ2enRvZWVaS3kxcW1ZNWRLdnJ4MkRCYkE2MjEwQ1kyUWswN1JGNFFKb3VmMkI1RXdRCjBYUUc0Z0RnS3ZCOXk5SlRkUHZvc3VRbldrMGtJWm5LOGtmM1cxVlBHL2ZuV1lVQ0F3RUFBYU5GTUVNd0VnWUQKVlIwVEFRSC9CQWd3QmdFQi93SUJBVEFPQmdOVkhROEJBZjhFQkFNQ0FRWXdIUVlEVlIwT0JCWUVGS2s1bUluUgp0bE9KWlNBd2dDMTRXaCtJNmJBN01BMEdDU3FHU0liM0RRRUJDd1VBQTRJQ0FRQ3Q2WElTYndsc1g1NlRuQzh6ClBvUWp4MUc1MGhwc0tsZG5xMy9aT05PQ242anZJLzk5c2Q0M2UxT080QlZYUUhzWTZSMC85ZnZ0OVZ6V0NEV2UKaEZMcG1lSXVaa2dSeERBY3RSTjZod3NTeGcwYVo2NmpQL1ROaTZzbFVNamxFWGF2MzZob3JLdnVVWUNPSkpvSgp5YTNRa3dMT2ZPOUtnTzNZdzROTjJLME5nUlpnYTYrdjYrU1JvVzk1Z2tnNUdoK3JTcHNnTTdOZlRIMWZFRjZoCjVKK0lBeXg2cDErQU9NVkhTWWhzc3ZUZ3hhM0xvSVJpc3dWWG1xVHRnUHUxaHpuZVczU1VrajYzWHJoM3JwYTMKdmI5Z3E3cDZpMEo5Y2VsZWx6NHpYempIRVlkMU14dEFSM0xIOGFZRERiVE9KOGtSQzhWL3VYUlVFakg1VXhqWgpTb3ZKOUVaZnZKWFBvNmRsQTByV0p5ME03b1AvTW9xeEIxTGJBaDlaM0p5LzBaNkd3RWxIdEpVZ2N2YmZ3VktoClRuQmRuV2J5d2NqZ0VFRjBlNGFiUjlhVTV2RHFiLzFrRndlbTNrM0cxdFRYMTZ4MWpvS1FEamhyNHJkRE42blYKQVpHN0tlSUJSdlRpcUYwdHB2WVdyLzB3c3RPVHZTdTkrM3pvVmt0UjdXR3d0c2sxUWNjRXJnOXFlNjVXeEdBdgpZREYzcnhhWEhpMU5VaDltRCtlQzVGbWd2N0Y3TDhLdzZDekM0bWxWNktIc2Zpdjk3MHlweDlJMFJzNDBzUnNWCm5iSDJTUnBUcEJSbDY4NTgvdkpMVVdtUkY3R1h6d3NQTndwWUFrSHFIZ1hKWmhWU2dtYi9TVWs0L2JaVXcyQVgKbktOUW1nVHdiaERMQXZuVUJhMUFWVnRCNFE9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCiMKIyBPd25lcjogQ049c2FsZXNmb3JjZS5jb20gSW50ZXJuYWwgUm9vdCBDQSAyIFNlY3VyaXR5LCBPPSJzYWxlc2ZvcmNlLmNvbSwgaW5jLiIsIEw9U2FuIEZyYW5jaXNjbywgU1Q9Q2FsaWZvcm5pYSwgQz1VUwojIElzc3VlcjogQ049c2FsZXNmb3JjZS5jb20gSW50ZXJuYWwgUm9vdCBDQSAyIFNlY3VyaXR5LCBPPSJzYWxlc2ZvcmNlLmNvbSwgaW5jLiIsIEw9U2FuIEZyYW5jaXNjbywgU1Q9Q2FsaWZvcm5pYSwgQz1VUwojIFNlcmlhbCBudW1iZXI6IDI4YjE5NDgwYWE0NjgxZGFjNzYwNjFmODAyZjlhZGY5NGUzYjc1MjUKIyBWYWxpZCBmcm9tOiBNb24gSnVsIDI0IDEzOjE2OjM3IFBEVCAyMDE3IHVudGlsOiBUaHUgSnVsIDIyIDEzOjE2OjM3IFBEVCAyMDI3CiMKLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUY4VENDQTltZ0F3SUJBZ0lVS0xHVWdLcEdnZHJIWUdINEF2bXQrVTQ3ZFNVd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2dZNHhDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFJREFwRFlXeHBabTl5Ym1saE1SWXdGQVlEVlFRSApEQTFUWVc0Z1JuSmhibU5wYzJOdk1SMHdHd1lEVlFRS0RCUnpZV3hsYzJadmNtTmxMbU52YlN3Z2FXNWpMakV6Ck1ERUdBMVVFQXd3cWMyRnNaWE5tYjNKalpTNWpiMjBnU1c1MFpYSnVZV3dnVW05dmRDQkRRU0F5SUZObFkzVnkKYVhSNU1CNFhEVEUzTURjeU5ESXdNVFl6TjFvWERUSTNNRGN5TWpJd01UWXpOMW93Z1k0eEN6QUpCZ05WQkFZVApBbFZUTVJNd0VRWURWUVFJREFwRFlXeHBabTl5Ym1saE1SWXdGQVlEVlFRSERBMVRZVzRnUm5KaGJtTnBjMk52Ck1SMHdHd1lEVlFRS0RCUnpZV3hsYzJadmNtTmxMbU52YlN3Z2FXNWpMakV6TURFR0ExVUVBd3dxYzJGc1pYTm0KYjNKalpTNWpiMjBnU1c1MFpYSnVZV3dnVW05dmRDQkRRU0F5SUZObFkzVnlhWFI1TUlJQ0lqQU5CZ2txaGtpRwo5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0NBZ0VBNVpLQWg3OW9JUGlzT044eG1nbXJhVk84RzRKQ0cveFVycUc5CnlRWFE4Si9oNVRIWEdWc3lEMGZqdUNwTVUzQXlqMGVGc0NSSjdVcU5PRllxbGwweldhcHhhb2gvT28xNktleW0KQUtuTFRBTFpOcWdNWkdXajNmM1hWRnBudTAwdm5oSTNSaUdyOEhDcjVwSVppMVhnbmVGeG43VGM4T2tNcDMwSQpwV0Jwa1JSQ284cXp1ZG5WNVM5NG54NWtGbFBpYndjWXpWYzBsZ3VHRlkwSEt4cStpTFV4MDQ2QmlQSkhGT1hBCnlmTlBSNGZBZ1YxUjlSTG04b1N4OTJzaTlNNXpHV1NUVGk4WG16YWk0cVBHNVhSTEw0RkxkamNSVkNLY3ZSVVIKTkk4Qm0xdUZCbmU3N0dobVhkRlpCUWpyNlpHL3VDWVFHbWlYRStWYi9DVnFxUTFUNS9velNieElRMTdIMHA5NQpraVplQjYzK1VQakdteHhKSUFlRnJKL2c4ODY5UHlUWmpIcVBWbUdDOEVxcjlMSStkQWNJRGVwblBwWk9xL3JmCkV6WVpqanBJYUxTMk1UbGY3Zk1UNWI3SklkV3hETjh1ZGd6am1xTEZkaHVFaHd3blhQYktqYmo5eGVNSTRvTm4Kd0c2YU0yU2hFVkRMcXFacVFPOUtIcUtkeGFrUTYva3Y0dCtrZ3ovd29OZlpFRFJtSEJ5Yk0rNndsNGtDZ1VkWgpxY0twbHRkM1RzWHhGQjhra0dldllPRkRoVEVUYmF2bjAwOFJlMk43ZFdZV3dPM21WQWxMaDBIRjFTMU5yczVLCldLUG5OKzFsL2pxNE9Tdm9ZeHRXQ01SdEE0dlIybEk4QUVmZUxQWFB4QjUyczVxTnlGQ29KOW82cFNSZG1aRXAKclFDc1NVY0NBd0VBQWFORk1FTXdFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBekFPQmdOVkhROEJBZjhFQkFNQwpBUVl3SFFZRFZSME9CQllFRk9MQjhmT3FOYVF4b3F4L1NaMHo4V29oRnRlTU1BMEdDU3FHU0liM0RRRUJDd1VBCkE0SUNBUUI2Tk9JYVZhN1YrajJqcmpqUVdkWWlRS1hPKzlWdjJmZEdlaXJPVjZiWWtwY3VOaU9JM0QrckVEMkgKSE40TFBaSU9UTjRaQXlmRDJTTGZhNXF3L2RpeHNnZzdEb2gwT0Voa1B0VjNKdTZYQ2xrTlplWDNza2VZK0V3awpuellyMlUraGp1SmcxRjU1c1FvTzhnKy80ZVA5WFJGc1o1cXpGMC9PUm5LZGhrY3FzRGZsWm01SEJWVGxoU0ZBCm16R1U1T0d0Z2hjak82NlRSc1RaSTVqamtTVDVLOUZ0d0l4aXZhR0FiS1lwOGx6QVhidngvUTJkdVdZMlJtcGQKaFkzcEp6OG5hWDJRcnVURTA3ZVZLSXVaSEorZzBTenZVQU1vQlNBZE1NVWdiYnpWcWt2ck9INGdNQlB3T2wyMApmQmUwMGUxd01CUkJHSzdBcUp1NkJsd3JuWTZTSWtLa0pvVDcvMU5iR1dmbGQvMEk1NjA3VnZEek9oc2hhSkVYClh5NXlaSTdlTXFxZzJEa05HYUlkN2pMdjI4ZUd6Z0VuWkJJVnMwajdieDdTNExKMTZzcW9XVythWmNUNklJUngKZGJGc1dGWjNNdkR5VHd3MUhoYnlWVnJ1aXNCQnVIVWhnWXVWblFydzRBNnd3VURoM0VCTU42VWNjVlNzTzl0MAplWEltNFVFUkVhWUJmcjArL3VkMGp1VnZ0L1UrWld2NUZaM2JXbVprVXExZlMwS2cxV0M5bFBrb3JDbHVsZGZ3ClJheWVTVmV1UVBwM2x4clZkT2h1dS9CK0h4cFhnVFlsYUQvRHN6VlB1SWlZeThNNm4xU3pKaDZtbzBGU2NIbWUKeEdnZHVwNzhYWDRIS2pLQVoyRWphVUpMQzdWSTd6bVRSMVFLWnZlR2VOa3c3b0t5c2c9PQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCiMKIyBPd25lcjogQ049c2FsZXNmb3JjZS5jb20gSW50ZXJuYWwgUm9vdCBDQSAyIEluZnJhLCBPPSJzYWxlc2ZvcmNlLmNvbSwgaW5jLiIsIEw9U2FuIEZyYW5jaXNjbywgU1Q9Q2FsaWZvcm5pYSwgQz1VUwojIElzc3VlcjogQ049c2FsZXNmb3JjZS5jb20gSW50ZXJuYWwgUm9vdCBDQSAyIEluZnJhLCBPPSJzYWxlc2ZvcmNlLmNvbSwgaW5jLiIsIEw9U2FuIEZyYW5jaXNjbywgU1Q9Q2FsaWZvcm5pYSwgQz1VUwojIFNlcmlhbCBudW1iZXI6IDdlMWUzYTg4ZTcyOTE1NTYxNGYzN2VjNDkxMmM2MzM0MDAxZGY3NDEKIyBWYWxpZCBmcm9tOiBNb24gSnVsIDI0IDEzOjIwOjE2IFBEVCAyMDE3IHVudGlsOiBUaHUgSnVsIDIyIDEzOjIwOjE2IFBEVCAyMDI3CiMKLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUY2ekNDQTlPZ0F3SUJBZ0lVZmg0NmlPY3BGVllVODM3RWtTeGpOQUFkOTBFd0RRWUpLb1pJaHZjTkFRRUwKQlFBd2dZc3hDekFKQmdOVkJBWVRBbFZUTVJNd0VRWURWUVFJREFwRFlXeHBabTl5Ym1saE1SWXdGQVlEVlFRSApEQTFUWVc0Z1JuSmhibU5wYzJOdk1SMHdHd1lEVlFRS0RCUnpZV3hsYzJadmNtTmxMbU52YlN3Z2FXNWpMakV3Ck1DNEdBMVVFQXd3bmMyRnNaWE5tYjNKalpTNWpiMjBnU1c1MFpYSnVZV3dnVW05dmRDQkRRU0F5SUVsdVpuSmgKTUI0WERURTNNRGN5TkRJd01qQXhObG9YRFRJM01EY3lNakl3TWpBeE5sb3dnWXN4Q3pBSkJnTlZCQVlUQWxWVApNUk13RVFZRFZRUUlEQXBEWVd4cFptOXlibWxoTVJZd0ZBWURWUVFIREExVFlXNGdSbkpoYm1OcGMyTnZNUjB3Ckd3WURWUVFLREJSellXeGxjMlp2Y21ObExtTnZiU3dnYVc1akxqRXdNQzRHQTFVRUF3d25jMkZzWlhObWIzSmoKWlM1amIyMGdTVzUwWlhKdVlXd2dVbTl2ZENCRFFTQXlJRWx1Wm5KaE1JSUNJakFOQmdrcWhraUc5dzBCQVFFRgpBQU9DQWc4QU1JSUNDZ0tDQWdFQXd2bm94QnFnTXVLNWJRQVNvOUVZSnVkejlMZjRxeEdZM1FjV0QweDBldk8rCmlDK2pZZDhHUmhjM21HdG1FbWtlOWVsWVYwWlYwZC9OdWtnbzk3RHYwUGJhOGEyeFhPTlJaLzdWMVRxYU8zMEQKaFNPSzBpRkRmclZiU1h1akE1alRaR25EWVI4eWw2dHZ6VmdtT0NYTGdGWHdxckpOSlFDSWkzYVJGU0ZPaEdUSAphcm1lblRsOXhUWVYxeHlITEs3Q2pmaHpBSjc3NnFXbVNoQTh0c1pacUZBVEVvMkJvbUYwbnZYWVhVdUkxbjJEClMxTWtTTjJmc3dhc3dQREthMnBhK1R2akRIN0ZNTFY3Tit3bGtaWjBDcGJ6Y2RhNUU0M2lyd3U0WFc3Q3ZiNUwKV3Qxcmo1VldWZHJ1ZVhscmZMTzZRUWJKL2YvYUI2WFYrUDN6ZEJxSGlKaHpyK0ZwNm1KRzlxKzN6bTJnSG1MbgpHUFZ1anNKdHBBWmpNSkR1bk81K0VqVTAxdTRpSDRwZThWODZ3NGF1NDdvUzFYOFpZRVFOd1ozYm1GZmxxb3JXClFwVHluT0VFNU5PY2tzay9EeW1aakY1YWxTckIxOWN0MmJ6dSt1Y1FKRG9YdmZFSGFaNWw4VlZpNThhZXFPcC8KbHRlMnV3bW1ScG93UXpuVzFyUFFuMURmK1dsTitQZDhxOWlNZ3pzaDZRRDBZRDRqenpqOG9mNTNYZmpGYlpVUwpMM0IwN0ZUeW5pdU1TUnN0ZEN4TExLTldJVkFYTXRkdFJ1WW5kWTA1SVJKWnZoeWVybGZCaEtDNVllWlliTFdqCkJNUXVJU3lVZ3BvTW0vOFdmaDJMdHJheHltM1JxZ3ptUFE0Yzh5STRhMEtZdllpZ1VmbWN3N3BqVXlXVzdCTUMKQXdFQUFhTkZNRU13RWdZRFZSMFRBUUgvQkFnd0JnRUIvd0lCQXpBT0JnTlZIUThCQWY4RUJBTUNBUVl3SFFZRApWUjBPQkJZRUZFRzhTYXAveHlwWFp2b3paZDI0RFlnWnBSQWRNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUNBUUN5CktFK3phZEpnUnNlRzlLRm9iMitxbmVlQ1VvWTA2NUN3UVRkQUZ2QmJNazlha1B4Qmt1cFFTQmZrbnJ3Ym1sdlgKeHpwWVVLeTFQMmZRaEdUWkpaR0xObXlBa3VSaUVDRzlRT2p1QmtFQlRpdGlYem0zMVZIZTBMT3d6Mjh6SjBpZQpKTjlZRUNVbGQ0d3hrd2JNVERhNGxpeDU2WHZOdGRPK2FMSWMvUHZoRjlJWUg0bTQzbk5CMUtwNmFFWEFDQ1l6CkdxYnpjYUJpTUdnTnVsK0dOVTZXdEdIc2xSVzhmc2dXUjFvbmE4SncyTE5RSk5aaS9kTmNSM3MzOVZGV3ZpQW8KOVEvdDEyQy8yc1FNOHV4K0h6R2dHWVJvM1ZneVhyRmRWT0wvV1d0R0thT0NWUW9taVNnaitSN1pDSWY2U0ZadApEUzRwVzZ2a3RWZUJ6c3lBdHhnSTFHdE5jMVI0ZjRlOTAwendoU3JVRUhGc05wWTRVbWp1RkllQVZ0ZldQdVZyCkJSc0dXb2xzUzZxMUwrMTNzMnFXV3FHNkFQb0RQN2xXbjBxWHNSZmVxZFdBc0JYV1NQVnhtQlJjanZBOFpNS3MKR0RPSXVnU1A1S0Q5b0hWRFB6NGlRbnRqTUJKdG0rRVM1YlRyRmhCcy93OWJzVUJ3WnBDOTZ6OTFzb0xhUXh6ZgpjOTFyNjdFaHZjcFNBRUtNRk85M09qVHYzOHludU9FeHVNMzdMUzVtTmNCM3FpMUcxRE5hK1dkYThVODdseGhDCk9iV05lUUlyTTJjWjJFSkxFd1NVbHQ0SE5XcFFsWm5IWWNHck1YdGUxeEp4K21IRGNnaU9hRkZYQjd4bVF0c3YKNy9oMjQ1dU9kdjJUU1pqQlgxVC90ZThNMVg3RFQyT01aUFVxNUdLSW9BPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQoKLS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUZNVENDQXhtZ0F3SUJBZ0lRUCtXdjQ2THRUL2xkRGUwNEsxczNJakFOQmdrcWhraUc5dzBCQVFzRkFEQlkKTVFzd0NRWURWUVFHRXdKVlV6RWRNQnNHQTFVRUNoTVVjMkZzWlhObWIzSmpaUzVqYjIwc0lHbHVZeTR4S2pBbwpCZ05WQkFNVElYTmhiR1Z6Wm05eVkyVXVZMjl0SUVsdWRHVnlibUZzSUZKdmIzUWdRMEVnTVRBZUZ3MHhOakExCk1qY3dNREF3TURCYUZ3MHlNVEExTWpZeU16VTVOVGxhTUZReEN6QUpCZ05WQkFZVEFsVlRNUjB3R3dZRFZRUUsKRXhSellXeGxjMlp2Y21ObExtTnZiU3dnYVc1akxqRW1NQ1FHQTFVRUF4TWRjMkZzWlhObWIzSmpaUzVqYjIwZwpTVzUwWlhKdVlXd2dRMEVnTVVFd2dnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUURFClBhZ2NxaDRQR00xdmNrQXJSSlhGaXNkcXBoL0lPbGV1emowNFNubTRieW52ekR5Z1pwc0ZVbXNlQ3BVWE5QWWcKTXZ6SW5QZ25NaWl2Sy81dnUzRGxuTlVYd3EwS2Y2c3V5dGZ2Z1dFL203WXF1OEtvNE1BeFA3ZnRmRUxxOGxGagpVMkExV2NXOEV3UGlTUUp3b0R2TjFBM0ZXbTBxeVJienlVQlExRmVmeDdDS0RYZ3dtMm5GL1p6Y09sWHV0ZHduCk9sd0NnL3hCMTNySUxpRmRSVVkweXdyQWpSNnQvd0VuZkpDVzFQWTE2aVE1UmNaM25JNkE5akN3bWRUYWJDb0UKQUpsN3RCd0h2alkxNGRSb3EvUTJoTHRkL2E4UnJINFFrUUFrWFQwdHcrdXBiUHVrbU51RjY3Z29MNmI2NnByMwoyVTlGdUhGaVBzRHc4R3hnSFdkNUFnTUJBQUdqZ2Zvd2dmY3dFZ1lEVlIwVEFRSC9CQWd3QmdFQi93SUJBREFPCkJnTlZIUThCQWY4RUJBTUNBUVl3WmdZRFZSMGZCRjh3WFRCYm9GbWdWNFpWYUhSMGNEb3ZMM0JyYVMxamNtd3UKYzNsdFlYVjBhQzVqYjIwdmIyWm1iR2x1WldOaEwzTmhiR1Z6Wm05eVkyVmpiMjFwYm1OellXeGxjMlp2Y21ObApZMjl0U1c1MFpYSnVZV3hTYjI5MFEwRXhMbU55YkRBcEJnTlZIUkVFSWpBZ3BCNHdIREVhTUJnR0ExVUVBeE1SClUzbHRZVzUwWldOUVMwa3RNaTAxTkRrd0hRWURWUjBPQkJZRUZNeG5GUzFuOU8velhhWjlLZ3BPb3Y0UWJsMkUKTUI4R0ExVWRJd1FZTUJhQUZLazVtSW5SdGxPSlpTQXdnQzE0V2grSTZiQTdNQTBHQ1NxR1NJYjNEUUVCQ3dVQQpBNElDQVFDVG1FS0lscSt0NWZoSWVCQTFjbllBVGowSjA4K0k4dTAxZUtUWWVQREo4UjJubWlydVY4MDBjNlBmCjhhUnhiR09NZ0h5RDVSR1NVU2ZZeVdyMGJzTy9aaVIxUnpRUFZXQ2VVN0RkSktQV2wybk92SUt6VTVsSUp1Qk4KYjFiTTZmY1B1dW14K1RPV2FDR2diNzdia0FEQjQwT0xUdmFTUFFhMWw0WXk1OHR4RytrSWU1YkE5WGk4QU55WQplaWdyZmR6RWhXelZHSWdxSFQyYnVqRHg2NDIyQUxjYStIK2JRS3ZLSm9WS1JlOVhLcFJCSk9RZjFSWEVtS212Ck00UnY3Um8rd2NEM1hoTnJ3OThRSlVEQ2ErQmtZV1VaS1puUG9ZUUZzMjBsNG9vOWRTdVZSTkRQNm1WeXlWbUMKYmZmLzZOQ1NVeGdlQ3Z2UWZ1cENEeldPdGFHR0txV01MTC9kREdxSlFHeTA2ZWFUVEhSdmNzYWNYYTlEYmFLTQpBempwelJBVzgvOEkxaW1qVlhkTFJTV1FGZEtLT21zN3NhTjQzcnJJemh0NSswbHd2dTVpbVdnSnNVd0lmRXlsCnVlWWZoS04wMHZ3RTYwTHBrUHJMWG1oWldsQVRSMHllMWE3eWtiSXJQNk1JTFJBOTZUNjYvU00zVFB0WWJ2MEgKNjZ2ZjlxNk5NTS9LY3RMU3QxRUU2SXMyYlc2dGNSR2JtZ2E3cmJKSmZUZEF4VlV1ZkZ1czlqOGY5a3BFSGt0TgpQalMvVS92cVZkbFUvOGVmWW5neVhsclBZeDFKUXFPeUc2VzY3dmlmcm85MitMbVRRYW0wSTBBTERhaklDcjE2ClhDaW9RTVEwbm5WTEFtT0ZwZ2hCZTdzYStjUzAyTnFyY09pdWJXSVN6akp0emtYQVVRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQotLS0tLUJFR0lOIENFUlRJRklDQVRFLS0tLS0KTUlJRmZ6Q0NBMmVnQXdJQkFnSVFEYTBvMkVQOGN6SmRUQnAxSUgxT2REQU5CZ2txaGtpRzl3MEJBUXNGQURCWQpNUXN3Q1FZRFZRUUdFd0pWVXpFZE1Cc0dBMVVFQ2hNVWMyRnNaWE5tYjNKalpTNWpiMjBzSUdsdVl5NHhLakFvCkJnTlZCQU1USVhOaGJHVnpabTl5WTJVdVkyOXRJRWx1ZEdWeWJtRnNJRkp2YjNRZ1EwRWdNVEFlRncweE5qQTEKTWpjd01EQXdNREJhRncweU5qQTFNall5TXpVNU5UbGFNRmd4Q3pBSkJnTlZCQVlUQWxWVE1SMHdHd1lEVlFRSwpFeFJ6WVd4bGMyWnZjbU5sTG1OdmJTd2dhVzVqTGpFcU1DZ0dBMVVFQXhNaGMyRnNaWE5tYjNKalpTNWpiMjBnClNXNTBaWEp1WVd3Z1VtOXZkQ0JEUVNBeE1JSUNJakFOQmdrcWhraUc5dzBCQVFFRkFBT0NBZzhBTUlJQ0NnS0MKQWdFQXZHTUVrZll1bVYzZ2ZZL2NjdUVoeHRsc1ZuMnpadThVTDNLY0tiRDAwR25OaEU5VFNuUEtvek8yMHEwcgpCVVRxRWxGVEVLYmdlMGFQVldTeUJ3R0ZkN1l2bVlxL0U4Q043U3lvYjRBdnBCMDNkSWM0aFJEaWpIL1ZwU0RkCnVvNUh4SytBTEJrcXBwUWppZGdpc1NRbWs4VTB6T21JaHorbTdnWjNXWG9WYVVqR1pWdzZVMzRXT0dNZTVvQWoKMUg4dVZwb2Y5NUMvS3pEUVp4eUNBUmNzR3BmU0tQQTJMLzdwMGJZUExQeHpFc0o1bXdSb0Y1MTR2L3hQMGZ0dAovNHQ2cmtkRGw5cUNkYWRHZisybFdZVHF2NVZaMTg1bXp4Ry8yRW5QajJJUWZNZWRaQTR3NHJaejB4Wko1OFB1CnZhTm02dmdlU21MNnFmUW9JbFBEMll1VnlmVzIvZjJmQnBySCsrWEJ5YUpsYW1xc0VxTUtrRW54Tk5BcWxjaXMKYW9Mc2sxb1NBMFhNQ25uZ3luRDFHYm9FdHB0b29LVkhkWnovUTVNWVV5cWVxNHExK00vSTdkSEVWbnBOOUVILwpScVRtUWdBZFNsY2NiKy9BVHZoMTZTdC9wQ2xYU1lOSThDelk5WEI0RmhlVkttUVlhUTFtZkZzeXBMSWhyWWt5CnNlUUFkcEZwVmNkUFJJL0ZYanBrQ2M2QmE0M0hUTjZ3YXRvQ3RqUFpONEE0clFrNnJMd2hJUDJKakk5NEVXWU8KZTZpYU9vUG9QVkxETHpydnp0b2VlWkt5MXFtWTVkS3ZyeDJEQmJBNjIxMENZMlFrMDdSRjRRSm91ZjJCNUV3UQowWFFHNGdEZ0t2Qjl5OUpUZFB2b3N1UW5XazBrSVpuSzhrZjNXMVZQRy9mbldZVUNBd0VBQWFORk1FTXdFZ1lEClZSMFRBUUgvQkFnd0JnRUIvd0lCQVRBT0JnTlZIUThCQWY4RUJBTUNBUVl3SFFZRFZSME9CQllFRktrNW1JblIKdGxPSlpTQXdnQzE0V2grSTZiQTdNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUNBUUN0NlhJU2J3bHNYNTZUbkM4egpQb1FqeDFHNTBocHNLbGRucTMvWk9OT0NuNmp2SS85OXNkNDNlMU9PNEJWWFFIc1k2UjAvOWZ2dDlWeldDRFdlCmhGTHBtZUl1WmtnUnhEQWN0Uk42aHdzU3hnMGFaNjZqUC9UTmk2c2xVTWpsRVhhdjM2aG9yS3Z1VVlDT0pKb0oKeWEzUWt3TE9mTzlLZ08zWXc0Tk4ySzBOZ1JaZ2E2K3Y2K1NSb1c5NWdrZzVHaCtyU3BzZ003TmZUSDFmRUY2aAo1SitJQXl4NnAxK0FPTVZIU1loc3N2VGd4YTNMb0lSaXN3VlhtcVR0Z1B1MWh6bmVXM1NVa2o2M1hyaDNycGEzCnZiOWdxN3A2aTBKOWNlbGVsejR6WHpqSEVZZDFNeHRBUjNMSDhhWUREYlRPSjhrUkM4Vi91WFJVRWpINVV4aloKU292SjlFWmZ2SlhQbzZkbEEwcldKeTBNN29QL01vcXhCMUxiQWg5WjNKeS8wWjZHd0VsSHRKVWdjdmJmd1ZLaApUbkJkbldieXdjamdFRUYwZTRhYlI5YVU1dkRxYi8xa0Z3ZW0zazNHMXRUWDE2eDFqb0tRRGpocjRyZERONm5WCkFaRzdLZUlCUnZUaXFGMHRwdllXci8wd3N0T1R2U3U5KzN6b1ZrdFI3V0d3dHNrMVFjY0VyZzlxZTY1V3hHQXYKWURGM3J4YVhIaTFOVWg5bUQrZUM1Rm1ndjdGN0w4S3c2Q3pDNG1sVjZLSHNmaXY5NzB5cHg5STBSczQwc1JzVgpuYkgyU1JwVHBCUmw2ODU4L3ZKTFVXbVJGN0dYendzUE53cFlBa0hxSGdYSlpoVlNnbWIvU1VrNC9iWlV3MkFYCm5LTlFtZ1R3YmhETEF2blVCYTFBVlZ0QjRRPT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ==",
      },
      rules: [
        {
          operations: ["CREATE", "UPDATE"],
          apiGroups: [""],
          apiVersions: ["v1"],
          resources: ["services"],
        },
        {
          operations: ["CREATE", "UPDATE"],
          apiGroups: ["mesh.sfdc.net"],
          apiVersions: ["v1"],
          resources: ["routingcontexts"],
        },
        {
          operations: ["CREATE", "UPDATE"],
          apiGroups: ["networking.istio.io"],
          apiVersions: ["v1alpha3"],
          resources: ["serviceentries"],
        },
      ],
      failurePolicy: "Fail",
      namespaceSelector: {
        matchLabels: {
          "istio-injection": "enabled",
        },
      },
    },
  ],
}
else "SKIP"
