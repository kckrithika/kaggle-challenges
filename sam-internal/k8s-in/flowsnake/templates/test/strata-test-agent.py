#! /usr/bin/env python

# Strata test agent script.  Polls configmap for new images to test and starts test runner pods
# when it finds them.  Accesses Kubernetes using a service account.

import sys
import time
import os
import httplib # must use httplib directly b/c urllib2 doesn't support PATCH verb
import ssl
import json

# Constants
k8s_api_host = "kubernetes.default.svc.cluster.local"
k8s_api_port = 443

# Overridable by env
ca_file_location = os.environ.get("KUBERNETES_CA_FILE") or "/cacerts/cabundle.pem"
requests_configmap = os.environ.get("CI_REQUESTS_CONFIGMAP") or "ci-test-requests"
my_namespace = os.environ.get("KUBERNETES_NAMESPACE") or "flowsnake-ci-tests"
runner_spec_template = os.environ.get("CI_RUNNER_TEMPLATE") or os.path.join(os.path.dirname(__file__), "runner_spec_template.json")
poll_interval_sec = os.environ.get("POLL_INTERVAL_SEC") or 60

# Globals derived from the above
configmap_api_path = "/api/v1/namespaces/%s/configmaps/%s" % (my_namespace, requests_configmap)

def logmsg(msg, *args):
    sys.stderr.write(msg % args)
    sys.stderr.write("\n")

def fetch_sa_token():
    with open("/var/run/secrets/kubernetes.io/serviceaccount/token", "r") as tokenfile:
        return "".join(tokenfile.readlines())


def k8s_request(path, verb="GET", data=None, content_type="application/json"):
    """
    Makes a generic k8s request using the SA credentials.
    :param path: K8s API path
    :param verb: HTTP verb to use on the request
    :param data: Data to pass in the request; will be converted to JSON
    :return: (int, str) pair of response status + response body
    """

    sslc = ssl.create_default_context(cafile=ca_file_location)
    sslc.check_hostname = False

    extra_headers = {
        "Authorization": "Bearer " + fetch_sa_token(),
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


def print_http_error(task, verb, reqpath, status, body):
    """
    When a request to k8s results in an unexpected error status, prints the error with some context
    """
    logmsg("Kubernetes API server returned unexpected error while performing action: %s.\n%s https://%s:%d%s\nResponse Status: %d, Response Body:\n%s\n",
           task, verb, k8s_api_host, k8s_api_port, reqpath, status, body)


def create_requests_configmap():
    """
    Used when the tag polling call finds that the map doesn't exist at all.
    """

    logmsg("Configmap %s does not exist; creating.", requests_configmap)

    reqpath = "/api/v1/namespaces/%s/configmaps" % my_namespace
    s, b = k8s_request(reqpath, verb="POST", data=json.dumps({
        "apiVersion": "v1",
        "kind": "ConfigMap",
        "data": {},
        "metadata": { "name": requests_configmap, "namespace": my_namespace }
    }))

    if s >= 400:
        print_http_error("creating test requests configmap", "POST", reqpath, s, b)
        sys.exit(1)

def get_requests():
    """
    Fetches the list of names/tags pending testing from the configmap.  If the configmap does not exist,
    creates it and returns an empty list.
    :return: List of (name, tag)s needing testing
    """
    s, b = k8s_request(configmap_api_path)
    if s == 404:
        create_requests_configmap()
        return []
    elif s != 200:
        print_http_error("retrieving test requests configmap", "GET", configmap_api_path, s, b)
        sys.exit(1)

    configmap_response = json.loads(b)
    configmap_data = configmap_response.get("data") or {}
    return configmap_data.items()


def remove_request(name):
    """
    Removes one reqest name from the requests configmap.
    """
    patch_req = [{"op": "remove", "path": "/data/%s" % name}]
    try:
        s, b = k8s_request(configmap_api_path, verb="PATCH", data=json.dumps(patch_req), content_type="application/json-patch+json")
        if s >= 300:
            logmsg("Warning: could not delete entry for runner name %s", name)
            print_http_error("removing tag from configmap", "PATCH (json-patch)", configmap_api_path, s, b)
    except httplib.HTTPException as x:
        logmsg("Warning: could not delete entry for runner name %s; exception contacting server: %s", name, x)

def runner_podspec(name, tag):
    with open(runner_spec_template) as template_file:
        raw_template = "".join(template_file.readlines())
        return raw_template.replace("{{TAG}}", tag).replace("{{NAME}}", name)


def schedule_pod(name, tag):
    """
    Schedule a runner pod for a name/tag.
    Returns whether the pod was successfully scheduled (either by this call or a previous one)
    """
    podspec = runner_podspec(name, tag)

    pod_path = "/api/v1/namespaces/%s/pods" % my_namespace
    try:
        s, b = k8s_request(pod_path, verb="POST", data=podspec)
        if s < 300:
            return True
        elif s == 409:
            logmsg("Warning: scheduling pod %s returned status 409; assuming pod is already running", name)
            return True
        else:
            print_http_error("scheduling test runner pod for tag %s" % tag, "POST", pod_path, s, b)
            return False
    except httplib.HTTPException as x:
        logmsg("Error communicating with kubernetes API server: %s", x)
        return False


########## MAIN METHOD ###########

logmsg("Starting Strata test runner agent.\nNamespace:\t%s\nConfigmap:\t%s\nPolling for requests every %s seconds\n",
       my_namespace, requests_configmap, poll_interval_sec)

while True:
    tags_to_process = get_requests()
    for name, tag in tags_to_process:
        logmsg("Submitting runner \"%s\" for tag %s...", name, tag)
        if schedule_pod(name, tag):
            remove_request(name)
    time.sleep(float(poll_interval_sec))

