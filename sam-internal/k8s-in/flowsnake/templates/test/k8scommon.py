
# Some common functions for making http calls against the Kubernetes API server from within a pod.
# Requires service accounts.

import os
import ssl
import httplib

# Constants
k8s_api_host = "kubernetes.default.svc.cluster.local"
k8s_api_port = 443

_ca_file_location = os.environ.get("KUBERNETES_CA_FILE") or "/certs/ca/cabundle.pem"


def _fetch_sa_token():
    with open("/var/run/secrets/kubernetes.io/serviceaccount/token", "r") as tokenfile:
        return "".join(tokenfile.readlines())

def k8s_apiserver_url():
    return "https://%s:%s" % (k8s_api_host, k8s_api_port)

def k8s_request(path, verb="GET", data=None, content_type="application/json"):
    """
    Makes a generic k8s request using the SA credentials.
    :param path: K8s API path.
    :param verb: HTTP verb to use on the request; defaults to GET.
    :param data: Data to pass in the request.
    :param content_type: If passing data, value of the Content-Type header. Defaults to application/json.
    :return: (int, str) pair of response status + response body
    """

    sslc = ssl.create_default_context(cafile=_ca_file_location)
    sslc.check_hostname = False

    extra_headers = {
        "Authorization": "Bearer " + _fetch_sa_token(),
        "Accept": "application/json"
    }

    if data:
        extra_headers["Content-Type"] = content_type

    conn = httplib.HTTPSConnection(host=k8s_api_host, port=k8s_api_port, context=sslc)
    try:
        conn.request(verb, path, body=data, headers=extra_headers)
        resp = conn.getresponse(buffering=True)
        return (resp.status, resp.read())
    finally:
        conn.close()
