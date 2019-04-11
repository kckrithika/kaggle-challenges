#! /usr/bin/env python

# Periodically polls kubernetes to find leftover resources that need to be deleted in the CI testing namespace.
# Resources will be deleted when they reach a maximum age, regardless of their running/stopped state at the time.
# Resources handled by this script are:
#   - test runner pods started by strata-test-agent.py, as determined by label
#   - any sparkapplication objects from any source

import os
from time import sleep
import json
from datetime import datetime, timedelta
from k8scommon import k8s_request
from httplib import HTTPException
import logging

# Some configuration parameters
poll_interval_minutes = int(os.environ.get("POLL_INTERVAL_MIN")) or 60
max_age_minutes = int(os.environ.get("MAX_AGE_MIN")) or 180
k8s_namespace = os.environ.get("KUBERNETES_NAMESPACE") or "flowsnake-ci-tests"

# derived value

logging.basicConfig(level=logging.INFO)


def get_old_resources(reqpath, list_kind, friendly_name):
    """
    Returns Kubernetes resources created before the max-age cutoff point.

    :param reqpath: K8s API path that will return the resources when GET'ed.
    :param list_kind: The expected "kind" of the returned k8s object from the api server call.
    :param friendly_name: A user-facing name of the resource being retrieved, exclusively used for logging.
    :return: list[str] of names of old resources of the requested type
    """

    try:
        s, b = k8s_request(reqpath)

        if s != 200:
            logging.warn("Error fetching %s in namespace %s. Status code %d, server returned: %s",
                          friendly_name, k8s_namespace, s, b)
            return []

        resource_list = json.loads(b)
    except HTTPException:
        logging.error("Error contacting API server while fetching list of %s in namespace %s", friendly_name, k8s_namespace, exc_info=True)
        return []
    except ValueError:
        logging.warn("Error fetching %s in namespace %s. Server returned invalid json: %s",
                     friendly_name, k8s_namespace, b, exc_info=True)
        return []

    if resource_list.get(u"kind") != unicode(list_kind):
        logging.warn("Error fetching %s in namespace %s. Expected kind %s but server returned %s",
                     friendly_name, k8s_namespace, list_kind, resource_list)

    old_resources = []

    max_age_timedelta = timedelta(minutes=max_age_minutes)
    now = datetime.utcnow()

    # This json parsing is fragile, but if it breaks it means the k8s server returned an object that doesn't
    # match its own specifications for list kinds.
    for rsc in resource_list[u"items"]:
        ts_str = str(rsc[u"metadata"][u"creationTimestamp"])
        try:
            ts = datetime.strptime(ts_str, "%Y-%m-%dT%H:%M:%SZ")
            if (now - ts) > max_age_timedelta:
                old_resources.append(str(rsc[u"metadata"][u"name"]))
        except ValueError:
            logging.warn("Found %s %s with unparseable creation timestamp \"%s\"",
            list_kind[:-4], rsc[u"metadata"].get(u"name"), ts_str, exc_info=True)

    return old_resources


def get_old_sparkapplications():
    res = get_old_resources("/apis/sparkoperator.k8s.io/v1beta1/namespaces/%s/sparkapplications" % k8s_namespace,
                             "SparkApplicationList", "sparkapplications")
    if len(res) > 0:
        logging.info("Found %d old spark applications", len(res))
    return res

def get_old_runner_pods():
    res = get_old_resources("/api/v1/namespaces/%s/pods?labelSelector=app=flowsnake-strata-test-runner" % k8s_namespace,
                             "PodList", "runner pods")
    if len(res) > 0:
        logging.info("Found %d old runner pods", len(res))
    return res

def delete_sparkapplication(sa_name):
    logging.info("Deleting old sparkapplication %s" % sa_name)
    reqpath = "/apis/sparkoperator.k8s.io/v1beta1/namespaces/%s/sparkapplications/%s" % (k8s_namespace, sa_name)
    try:
        s, b = k8s_request(reqpath, verb="DELETE")
        if s >= 300:
            logging.warn("Error deleting sparkapplication %s in namespace %s; server returned status %d, message: %s",
                         sa_name, k8s_namespace, s, b)
    except HTTPException:
        logging.warn("Error contacting API server when deleting sparkapplication %s in namespace %s",
                     sa_name, k8s_namespace, exc_info=True)

def delete_pod(pod_name):
    logging.info("Deleting old runner pod %s", pod_name)
    reqpath = "/api/v1/namespaces/%s/pods/%s" % (k8s_namespace, pod_name)
    try:
        s, b = k8s_request(reqpath, verb="DELETE")
        if s >= 300:
            logging.warn("Error deleting pod %s in namespace %s; server returned status %d, message: %s",
                         pod_name, k8s_namespace, s, b)
    except HTTPException:
        logging.warn("Error contacting API server when deleting pod %s in namespace %s",
                     pod_name, k8s_namespace, exc_info=True)

############### Main Script ##################

logging.info("\nStarting Strata test resource cleanup.\nNamespace: %s\nPolling every %d minutes.",
             k8s_namespace, poll_interval_minutes)

while True:
    for sa_name in get_old_sparkapplications():
        delete_sparkapplication(sa_name)
    for pod_name in get_old_runner_pods():
        delete_pod(pod_name)
    sleep(float(poll_interval_minutes) * 60)
