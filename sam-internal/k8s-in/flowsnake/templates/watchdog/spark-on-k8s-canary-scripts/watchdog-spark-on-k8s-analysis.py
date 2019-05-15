#!/usr/bin/env python

"""
Runs the Spark Operator Watchdog script (e.g. watchdog-spark-on-k8s.sh). Performs analysis on the script's output to
to classify failed runs by type of failure. Output and error code are then returned unmodified to the caller
(cliChecker Watchdog Go code).

The purpose of this program is to make it easier to determine which types of failures are the primary causes of
script failures (and thus Flowsnake Service availability gaps). Determining what went wrong with a failed run requires
carefully looking through the log, which was previously a tedious and manual process.

Analysis result is written to stderr after the stderr output of the script itself. The analysis results can be
tallied relatively easily with Splunk (TODO: query goes here). In the future consider reporting them to Funnel.
"""

from argparse import ArgumentParser
import os
import re
import subprocess
import sys

# ------------ metrics-related code adapted from
# https://git.soma.salesforce.com/monitoring/collectd-write_funnel_py/blob/18ef838f5a6221450e51ee2d7beb984adb0a3dc7/funnel_writer.py
# ------------
import httplib
import time
import json
from os import R_OK, access
from os.path import isfile, exists
import collections
import logging
import socket

MAX_TRIES = 10

logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(filename)s:%(lineno)d %(levelname)5s - %(message)s'
)

Metric = collections.namedtuple(
    'Metric', ('service', 'name', 'value', 'timestamp', 'context', 'tags'))

MetricContext = collections.namedtuple(
    'MetricContext', ('datacenter', 'superpod', 'pod', 'host'))


class MetricEncoder(json.JSONEncoder):
    def encode(self, obj):
        if isinstance(obj, (list, tuple)):
            batched_list = []
            for o in obj:
                batched_list.append(self._translate(o))
            result = json.JSONEncoder.encode(self, batched_list)
        else:
            result = json.JSONEncoder.encode(self, self._translate(obj))
        logging.debug('Encoded metric(s): %s' % result)
        return result

    @staticmethod
    def _translate(metric):
        assert isinstance(metric, Metric)
        all_tags = {}
        all_tags.update(metric.context._asdict())
        all_tags.update(metric.tags)
        metric_content = {
            'service': metric.service,
            'metricName': metric.name,
            'metricValue': metric.value,
            'timestamp': metric.timestamp,
            'tags': all_tags,
        }
        return metric_content


class FunnelException(Exception):
    pass


class FunnelClient():
    def __init__(self, funnel_endpoint,
                 metric_scheme_fingerprint="AVG7NnlcHNdk4t_zn2JBnQ",
                 timeout_seconds=10,
                 funnel_debug=False,
                 cert_path=None,
                 key_path=None,
                 http_allowed=False,
                 ):
        self.funnel_endpoint = funnel_endpoint
        self.fingerprint = metric_scheme_fingerprint
        self.timeout = timeout_seconds
        self.debug = str(funnel_debug).lower()
        self.certpath = cert_path
        self.keypath = key_path
        self.https_allowed = http_allowed

        self.url = '/funnel/v1/publishBatch?avroSchemaFingerprint=%s&debug=%s' % (self.fingerprint, self.debug)
        self.has_certs = self.certpath and exists(self.certpath) and isfile(self.certpath) and \
                         access(self.certpath, R_OK) and \
                         self.keypath and exists(self.keypath) and isfile(self.keypath) and access(self.keypath, R_OK)

    def post_request(self, post_data, numberofmetrics, tries):
        try:
            # We rely on the fact that in idb if the funnel-server doesn't have a port
            # then it's using HTTPS, else HTTP
            if ":" not in self.funnel_endpoint and self.has_certs and self.https_allowed:
                connection = httplib.HTTPSConnection(self.funnel_endpoint,
                                                     key_file=self.keypath, cert_file=self.certpath,
                                                     timeout=self.timeout)
            else:
                connection = httplib.HTTPConnection(self.funnel_endpoint, timeout=self.timeout)

            headers = {"Content-type": "application/json"}

            connection.request('POST', self.url, post_data, headers)
            response = connection.getresponse()
            response_body = response.read()
            logging.debug("POST %s -> %s (metricssize:%d merticsnum:%d tries:%d)" % (
                self.funnel_endpoint, response_body, sys.getsizeof(post_data), numberofmetrics, tries))

            if response.status != 200:
                return False, response_body
            return True, None
        except Exception as e:
            return False, str(e)

    def publish_batch(self, metrics):
        sdata = json.dumps(metrics, cls=MetricEncoder)
        message = ''
        for retry in range(0, MAX_TRIES):
            success, message = self.post_request(sdata, len(metrics), retry+1)
            if success:
                return True
        raise FunnelException(message)
# --------- End adapted metrics code


parser = ArgumentParser()
mode_group = parser.add_mutually_exclusive_group(required=True)
mode_group.add_argument("--command", action='store_true',
                    help="Spark Operator Watchdog script (and arguments) to execute")
mode_group.add_argument("--analyze", dest="analyze",
                    help="Process the provided static content rather than executing a script")
mode_group.add_argument("--test-dir", dest="test_dir",
                        help="Process all files in the provided directory as static content. First line of each file must be asserted result.")
parser.add_argument("--sfdchosts",
                    help="Path of SAM sfdchosts file. Required for metrics generation")
parser.add_argument("--watchdog-config",
                    help="Path of SAM Watchdog config file. Required for metrics generation")
parser.add_argument("--hostname",
                    help="Override hostname to use when determining metrics configuration")
parser.add_argument("--metrics", action='store_true',
                    help="If set, metrics will be written indicating the analysis result")
args, additional_args = parser.parse_known_args()

simple_regex_tests = {
    # Driver pod's init container errors out. Cause TBD.
    'DRIVER_INIT_ERROR': re.compile('Pod change detected.*-driver changed to Init:Error'),
    # Scheduler bug in Kubernetes <= 1.9.7 that randomly prevents re-use of pod name. No longer expected because pod names are now unique.
    'SCHEDULER_ASSUME_POD': re.compile("FailedScheduling.*AssumePod failed: pod .* state wasn't initial but get assumed")
}

r_driver_context_submitted = re.compile(r'SparkContext.* - Submitted application')
r_driver_context_jar_added = re.compile(r'SparkContext.* - Added JAR file:')
r_executor_allocator_ran = re.compile(r'ExecutorPodsAllocator.* - Going to request [0-9]* executors from Kubernetes')
r_timeout_running = re.compile(r'Timeout reached. Aborting wait for SparkApplication .* even though in non-terminal state RUNNING.')
#r_ driver_running_event = re.compile(r'SparkDriverRunning\s+([0-9]+)([sm])\s+spark-operator\s+Driver .* is running')
r_driver_running_epoch = re.compile(r'\[([0-9]+)\] .* - Pod change detected: .*-driver changed to Running.')
r_exec_running_epoch = re.compile(r'\[([0-9]+)\] .* - Pod change detected: .*-exec-[0-9]+ changed to Running.')

def analyze_helper(combined_output):
    for code, regex in simple_regex_tests.iteritems():
        if regex.search(combined_output):
            return code

    # Check for termination due to timeout.
    if r_timeout_running.search(combined_output):

        # Check for failures after the driver is running
        m = r_driver_running_epoch.search(combined_output)
        if m:
            # Check for failure cases that occur after the driver is runnning
            driver_running_epoch = int(m.group(1))
            # This block digs into driver logs
            if r_driver_context_submitted.search(combined_output):
                # Check for failure cases that occur after the application JAR has been loaded
                if r_driver_context_jar_added.search(combined_output):
                    # Requesting executors is the next thing to do after adding the application JAR. Unknown why it sometimes doesn't happen.
                    if not r_executor_allocator_ran.search(combined_output):
                        return 'EXECUTOR_ALLOCATOR_DID_NOT_RUN'
            # Figure out when the executor started

            # If we can't figure out a specific reason, look into what part was slow.
            m = r_exec_running_epoch.search(combined_output)
            if m:
                exec_running_epoch = int(m.group(1))
                if exec_running_epoch - driver_running_epoch >= 180:
                    # We're likely to not complete in time if it takes this long for the driver to launch an executor.
                    # If this is a frequent occurrence, we should get more precise. Specifically, when did
                    # r_executor_allocator_ran happen? That would shed some light on whether the driver was slow to
                    # request the executor, or whether the executor was slow to start.
                    # (In the case of timeout_executor_late_001.txt, it took over three minutes from driver Running to
                    # executors requested.)
                    return "TIMEOUT_EXECUTOR_LATE"

            # NOTE: do not put checks for error messages here. Error messages are more informative that timeouts, so if
            # we have an error message, we should return it. Therefore put all error message checks above the timeout
            # checks.
            return 'UNRECOGNIZED_TIMEOUT_DRIVER_RUNNING'
        else:
            return "UNRECOGNIZED_TIMEOUT_DRIVER_NOT_RUNNING"
    return "UNRECOGNIZED"


def analyze(combined_output):
    result = analyze_helper(combined_output)
    if metrics_enabled:
        emit_metrics(result)
    return result


def emit_metrics(result):
    funnel_client = FunnelClient(funnel_endpoint)
    metric_context = MetricContext(kingdom, superpod, pod, hostname)
    m_list = [
        Metric('sam.watchdog', ['cliChecker', 'SparkOperatorTest', 'FailureAnalysis'], 1, int(time.time()), metric_context, {'class': result})
    ]
    try:
        funnel_client.publish_batch(m_list)
    except Exception as e:
        logging.exception('Failed to send %d metrics to funnel' % len(m_list))

metrics_enabled = False
if args.metrics:
    if args.hostname:
        hostname = args.hostname
    else:
        hostname = socket.gethostname()
    if not args.sfdchosts or not args.watchdog_config:
        logging.error("Cannot emit metrics: --sfdchosts and --watchdog-config are both required")
    else:
        try:
            with open(args.sfdchosts) as f:
                host_data = json.load(f)
                try:
                    host_entry = next(e for e in host_data['hosts'] if e['hostname'] == hostname)
                    kingdom = host_entry['kingdom'].upper()
                    superpod = host_entry['superpod'].upper()
                    pod = host_entry['estate']
                except StopIteration:
                    raise StandardError("Cannot emit metrics: host %s not found in sfdchosts" % hostname)
            with open(args.watchdog_config) as f:
                funnel_endpoint = json.load(f)['funnelEndpoint']
            metrics_enabled = True
        except StandardError as e:
            logging.exception("Cannot emit metrics: error parsing sfdchosts %s and watchdog-config %s",
                              args.sfdchosts, args.watchdog_config)


if args.command:
    try:
        print subprocess.check_output(additional_args, stderr=subprocess.STDOUT)
        sys.exit(0)
    except subprocess.CalledProcessError as e:
        print e.output
        print "Analysis of failure: {}".format(analyze(e.output))
        sys.exit(e.returncode)
elif args.analyze:
    with open(args.analyze, 'r') as file:
        result = analyze(file.read())
        print result
elif args.test_dir:
    success = True
    for filename in os.listdir(args.test_dir):
        with open(os.path.join(args.test_dir, filename), 'r') as file:
            data = file.read()
            expect, contents = data.split('\n', 1)
            result = analyze(contents)
            if result == expect:
                print (u"\u2713 {}: {}".format(filename, expect))
            else:
                print (u"\u2718 {}: {} expected, {} obtained".format(filename, expect, result))
                success = True
    if not success:
        sys.exit(1)
else:
    print "Bug: argparse failed to set a known operation mode."
    sys.exit(1)
