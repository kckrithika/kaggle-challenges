#! /usr/bin/env python

# Strata test agent script.  Polls configmap for new images to test and starts test runner pods
# when it finds them.  Accesses Kubernetes using a service account.

import sys
import time
import os
from k8scommon import k8s_request, k8s_apiserver_url
from httplib import HTTPException
import json
import logging

# Overridable by env
requests_configmap = os.environ.get("CI_REQUESTS_CONFIGMAP") or "ci-test-requests"
my_namespace = os.environ.get("KUBERNETES_NAMESPACE") or "flowsnake-ci-tests"
runner_spec_template = os.environ.get("CI_RUNNER_TEMPLATE") or os.path.join(os.path.dirname(__file__), "runner_spec_template.json")
poll_interval_sec = os.environ.get("POLL_INTERVAL_SEC") or 60

# Globals derived from the above
configmap_api_path = "/api/v1/namespaces/%s/configmaps/%s" % (my_namespace, requests_configmap)


logging.basicConfig(level=logging.INFO)


def print_http_error(task, verb, reqpath, status, body):
    """
    When a request to k8s results in an unexpected error status, prints the error with some context
    """
    logging.error("Kubernetes API server returned unexpected error while performing action: %s.\n%s %s%s\nResponse Status: %d, Response Body:\n%s\n",
           task, verb, k8s_apiserver_url(), reqpath, status, body)


def create_requests_configmap():
    """
    Used when the tag polling call finds that the map doesn't exist at all.
    """

    logging.info("Configmap %s does not exist; creating.", requests_configmap)

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
            logging.warn("Warning: could not delete entry for runner name %s", name)
            print_http_error("removing tag from configmap", "PATCH (json-patch)", configmap_api_path, s, b)
    except HTTPException:
        logging.error("Warning: could not delete entry for runner name %s; exception contacting server", name, exc_info=True)

def runner_podspec(name, tag):
    with open(runner_spec_template) as template_file:
        raw_template = "".join(template_file.readlines())
        return raw_template.replace("{{TAG}}", tag).replace("{{NAME}}", name)

def check_k8s_status(status_string, **kwargs):
    try:
        parsed_status = json.loads(status_string)
        for k, v in kwargs.items():
            if unicode(parsed_status[unicode(k)]) != unicode(v):
                return False
        return True
    except ValueError:  # JSON parse error
        return False
    except KeyError:  # Key/Value not in map
        return False

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
        elif check_k8s_status(b, code=409, reason="AlreadyExists"):
            logging.warn("Warning: scheduling pod %s returned status: AlreadyExists.", name)
            return True
        else:
            print_http_error("scheduling test runner pod %s for tag %s" % (name, tag), "POST", pod_path, s, b)
            return False
    except HTTPException:
        logging.error("Error communicating with kubernetes API server while scheduling pod", exc_info=True)
        return False


########## MAIN METHOD ###########

logging.info("Starting Strata test runner agent.\nNamespace:\t%s\nConfigmap:\t%s\nPolling for requests every %s seconds\n",
       my_namespace, requests_configmap, poll_interval_sec)

while True:
    tags_to_process = get_requests()
    for name, tag in tags_to_process:
        logging.info("Submitting runner \"%s\" for tag %s...", name, tag)
        if schedule_pod(name, tag):
            remove_request(name)
    time.sleep(float(poll_interval_sec))

