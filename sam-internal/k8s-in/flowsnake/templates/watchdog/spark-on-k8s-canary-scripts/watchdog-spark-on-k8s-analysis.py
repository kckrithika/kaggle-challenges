#!/usr/bin/env python
# coding: utf-8

"""
Runs the Spark Operator Watchdog script (e.g. watchdog-spark-on-k8s.sh). Performs analysis on the script's output to
to classify failed runs by type of failure. Output and error code are then returned (with minimal additional decoration)
to the caller (i.e. to the cliChecker Watchdog Go code). Additionally computes timing metrics (e.g. interval between
Spark Driver requesting an exectuor and executor pod running). These timing metrics are reported for successful runs
as well.

The purpose of this program is to make it easier to determine which types of failures are the primary causes of
script failures (and thus Flowsnake Service availability gaps). Determining what went wrong with a failed run requires
carefully looking through the log, which was previously a tedious and manual process.

Example: running analysis on test data:
$ flowsnake/templates/watchdog/spark-on-k8s-canary-scripts/watchdog-spark-on-k8s-analysis.py --test-dir flowsnake/templates/watchdog/spark-on-k8s-canary-scripts/tests
✓ timeout_executor_slow_pod_creation_001.txt: TIMEOUT_EXECUTOR_SLOW_POD_CREATION
✓ driver_init_error_001.txt: DRIVER_INIT_ERROR
✓ etcd_no_leader_001.txt: {"class": "TIMEOUT_EXECUTOR_SLOW_POD_CREATION", "exception": "KubernetesClientException", "exception_cause": "ETCD_NO_LEADER"}
✓ exec_allocator_did_not_run_002.txt: EXECUTOR_ALLOCATOR_DID_NOT_RUN
✓ etcd_no_leader_002.txt: {"class": "SPARK_SUBMIT_FAILED", "exception": "KubernetesClientException", "exception_cause": "ETCD_NO_LEADER"}
✓ exec_allocator_did_not_run_001.txt: EXECUTOR_ALLOCATOR_DID_NOT_RUN
✓ timeout_executor_slow_pod_creation_002.txt: TIMEOUT_EXECUTOR_SLOW_POD_CREATION
✓ timeout_executor_slow_pod_creation_003.txt: TIMEOUT_EXECUTOR_SLOW_POD_CREATION
✓ timeout_exec_allocator_late_001.txt: TIMEOUT_EXECUTOR_ALLOCATOR_LATE
✓ scheduler_assume_pod_001.txt: SCHEDULER_ASSUME_POD

Example: as above, but also writing metrics to Funnel:
$ flowsnake/templates/watchdog/spark-on-k8s-canary-scripts/watchdog-spark-on-k8s-analysis.py --test-dir flowsnake/templates/watchdog/spark-on-k8s-canary-scripts/tests --metrics --sfdchosts /sfdchosts/hosts.json --watchdog-config /config/watchdog.json --host fs1shared0-flowsnakemastertest1-3-prd.eng.sfdc.net

Example: as above, but writing to Funnel using defaults appropriate for local development:
$ flowsnake/templates/watchdog/spark-on-k8s-canary-scripts/watchdog-spark-on-k8s-analysis.py --test-dir flowsnake/templates/watchdog/spark-on-k8s-canary-scripts/tests --metrics --dev

Metrics written with the --dev flag can be found using Argus expressions
GROUPBYTAG(-15m:sam.watchdog.CORP.NONE.flowsnake-local-test:cliChecker.SparkOperatorTest.FailureAnalysis:none, #class#, #exception#, #exception_cause#, #SUM#)
or, to also group by app:
GROUPBYTAG(-15m:sam.watchdog.CORP.NONE.flowsnake-local-test:cliChecker.SparkOperatorTest.FailureAnalysis:none, #app#, #class#, #exception#, #exception_cause#, #SUM#)
and for timing:
GROUPBYTAG(-15m:sam.watchdog.CORP.NONE.flowsnake-local-test:cliChecker.SparkOperatorTest.Times.*:none, #app#, #succeeded#, #AVERAGE#)

The GROUPBYTAG facilitates display of optional tags per
https://gus.lightning.force.com/lightning/r/0D5B000000sQcBnKAK/view

Real results from live fleets can be found using Argus expressions
GROUPBYTAG(-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.FailureAnalysis:none, #class#, #exception#, #exception_cause#, #SUM#)
GROUPBYTAG(-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.FailureAnalysis:none, #app#, #class#, #exception#, #exception_cause#, #SUM#)
GROUPBYTAG(-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.Times.*:none, #app#, #succeeded#, #AVERAGE#)

Or to separate out estates and/or data centers, include the #estate# and/or #dc# tag in the grouping:
GROUPBYTAG(-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.FailureAnalysis:none, #estate#, #class#, #exception#, #exception_cause#, #SUM#)

To view all metric and tag permutations, omit grouping and aggregation:
-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.FailureAnalysis:none

To view timing metrics:
-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.Times.*:avg
Or, to separate out times per spark application:
-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.Times.*{app=*}:avg

To view all metric and tag permutations, omit grouping and aggregation:
-15m:sam.watchdog.*.NONE.*flowsnake*:cliChecker.SparkOperatorTest.Times.*:none

TODO: Make a dashboard
"""

from __future__ import print_function
from argparse import ArgumentParser
import calendar
import os
import re
import subprocess
import sys


"""
Failure analysis metric. Recorded only when the result is a failure. Value always is 1. Metric tags indicate
analysis of what went wrong.
"""
FAILURE_ANALYSIS_METRIC_NAME = 'FailureAnalysis'
#
# Analysis dict keys
# The result of the analysis is a string,string map, which is then sent to Argus as tags on a metric.
CLASSIFICATION = 'class'  # Overall classification of the failure
EXCEPTION = 'exception'  # Java class of most pertinent Exception, if any
EXCEPTION_CAUSE = 'exception_cause'  # Determined cause of the Exception
ANALYSIS_KEYS = [CLASSIFICATION, EXCEPTION, EXCEPTION_CAUSE]


"""
Timing analysis metrics. Recorded whenever the data could be obtained, including for successful runs. Value is time in
seconds. Each time has its own metric.
"""
TIMING_METRIC_SUCCESS_TAG = 'succeeded'

# Interval between the creating of the Spark Application and detecting the driver pod. 
TIMING_METRIC_NAME_DRIVER_POD_DETECTED = 'AppCreationToDriverPodDetected'
# Interval between pending driver pod and scheduled driver pod. Only present when the driver got stuck pending instead of being directly created.
TIMING_METRIC_NAME_DRIVER_POD_PENDING_DELAY = 'DriverPodSchedulingDelay'
# Interval between driver pod scheduled and driver pod Running
TIMING_METRIC_NAME_DRIVER_POD_INITIALIZATION = 'DriverPodInitialization'
# Interval between driver pod Running and driver logging that the Spark App was submitted
TIMING_METRIC_NAME_DRIVER_APP_SUBMIT = 'DriverPodAppSubmit'
# Interval between driver pod logging that the Spark App was submitted and that the JAR was added. (Believe that JAR added is logged after all prep work prior to requesting executors has been completed)
TIMING_METRIC_NAME_DRIVER_APP_LOAD = 'DriverPodAppLoad'
# Interval between driver pod logging that an executors was requested and that it starts doing work
TIMING_METRIC_NAME_EXECUTOR_WAIT_TOTAL = 'ExecutorTotalWait'
# Interval between the driver requesting an executor and detecting the executor pod.
TIMING_METRIC_NAME_EXEC_POD_DETECTED = 'ExecutorAllocatorToPodDetected'
# Interval between pending executor pod and scheduled executor pod. Only present when the executor got stuck pending instead of being directly created.
TIMING_METRIC_NAME_EXEC_POD_PENDING_DELAY = 'ExecutorPodSchedulingDelay'
# Interval between executor pod scheduled and executor pod Running
TIMING_METRIC_NAME_EXEC_POD_INITIALIZATION = 'ExecutorPodInitialization'
# Interval between executor pod running and executor picking up work from the driver
TIMING_METRIC_NAME_EXEC_REGISTRATION = 'ExecutorPodRegistration'
# Interval between executor picking up work from the driver and job completion
TIMING_METRIC_NAME_JOB_RUNTIME = 'JobRunTime'
# Interval between job completion and watchdog script completion
TIMING_METRIC_NAME_CLEAN_UP = 'CleanUp'


TAG_APP = 'app'  # Name of the Spark Application. Same across concurrent watchdog instances. Roughly represents feature being tested.
TAG_APP_ID = 'app_id'  # Id of the Spark Application. Unique across concurrent executions but recurring over time.
TAG_ESTATE = 'estate'  # Estate this metric was emitted from ("pod" of the Argus scope)
TAG_DC = 'dc'  # Datacenter this metric was emitted from

# ------------ Funnel client code adapted from
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
THIS_SCRIPT = os.path.basename(__file__)

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
parser.add_argument("--dev", action='store_true',
                    help="If set, metrics can be written without specifying --sfdchosts or --watchdog-config. Uses hard-coded PRD Funnel endpoint, dc:CORP, superpod:NONE, pod:flowsnake-local-test.")
parser.add_argument("--estate",
                    help="Override estate (Argus pod) to use when determining metrics configuration. For use in combination with --dev")
args, additional_args = parser.parse_known_args()

simple_regex_tests = {
    # Driver pod's init container errors out. Cause TBD.
    'DRIVER_INIT_ERROR': re.compile(r'Pod change detected.*-driver changed to Init:Error'),
    # Scheduler bug in Kubernetes <= 1.9.7 that randomly prevents re-use of pod name. No longer expected because pod names are now unique.
    'SCHEDULER_ASSUME_POD': re.compile(r"FailedScheduling.*AssumePod failed: pod .* state wasn't initial but get assumed"),
    # This should be accompanied by a useful Exception
    'SPARK_CONTEXT_INIT_ERROR': re.compile(r'Error initializing SparkContext'),
    # This one might be due to IP exhaustion; need to check kubelet logs. https://salesforce.quip.com/i0ThASBMoHqf#VCTACATj2IO
    'DOCKER_SANDBOX': re.compile(r'Failed create pod sandbox'),
    'KUBECTL_MAX_TRIES_TIMEOUT': re.compile(r'Invocation \([0-9/]*\) of \[kubectl .*\] failed \(timed out \([0-9]*s\)\). Giving up.'),
    'DRIVER_EVICTED': re.compile(r'NodeControllerEviction.*node-controller.*Marking for deletion Pod .*-driver'),
    'MADKUB_INIT_EMPTY_DIR': re.compile(r'Error: failed to start container "madkub-init": .*kubernetes.io~empty-dir/datacerts'),
}

metrics_enabled = False
if args.metrics:
    hostname = args.hostname if args.hostname else socket.gethostname()
    if args.dev:
        funnel_client = FunnelClient('ajna0-funnel1-0-prd.data.sfdc.net:80')
        estate = args.estate if args.estate else 'flowsnake-local-test'
        metric_context = MetricContext('CORP', 'NONE', estate, hostname)
        metrics_enabled = True
    elif not args.sfdchosts or not args.watchdog_config:
        logging.error("Cannot emit metrics: --sfdchosts and --watchdog-config are both required (or --dev)")
    else:
        if args.estate:
            logging.error("Cannot specify estate except in combination with --dev")
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
                funnel_client = FunnelClient(funnel_endpoint)
                metric_context = MetricContext(kingdom, superpod, pod, hostname)
                metrics_enabled = True
            except StandardError as e:
                logging.exception("Cannot emit metrics: error parsing sfdchosts %s and watchdog-config %s",
                                  args.sfdchosts, args.watchdog_config)

r_app_created = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - sparkapplication "(?P<app>.*)" created')
r_driver_pod_creation_event = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-driver: (?P<state>.*) on host.*')
r_driver_pod_creation_event_pending = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-driver: Pending on host.*')
r_driver_pod_initializing = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-driver(:| changed to) (PodInitializing|Init)')
r_driver_pod_running = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-driver(:| changed to) Running')
# r_driver_pod_change_event = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-driver changed to (?P<state>[^ ]*).*\(previously (?P<previous>.*)\)')
r_spark_submit_failed = re.compile(r'failed to run spark-submit')
r_driver_context_app_submitted = re.compile(r'(?P<spark_time>[- :0-9]*) INFO.*SparkContext.* - Submitted application')
r_driver_context_jar_added = re.compile(r'(?P<spark_time>[- :0-9]*) INFO.*SparkContext.* - Added JAR file:')
r_exec_allocator = re.compile(r'(?P<spark_time>[- :0-9]*) INFO.*ExecutorPodsAllocator.* - Going to request [0-9]* executors from Kubernetes')
r_timeout_running = re.compile(r'Timeout reached. Aborting wait for SparkApplication .* even though in non-terminal state RUNNING.')
#r_ driver_running_event = re.compile(r'SparkDriverRunning\s+([0-9]+)([sm])\s+spark-operator\s+Driver .* is running')
r_exec_pod_creation_event = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-exec-[0-9]+: (?P<state>.*) on host.*')
r_exec_pod_creation_event_pending = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-exec-[0-9]+: Pending on host.*')
r_exec_pod_initializing = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-exec-[0-9]+(:| changed to) (PodInitializing|Init)')
r_exec_pod_running = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - Pod change detected: .*-exec-[0-9]+ changed to Running.')
r_exec_registered_time = re.compile(r'(?P<spark_time>[- :0-9]*) INFO.*KubernetesClusterSchedulerBackend.*Registered executor')
r_job_finished = re.compile(r'(?P<spark_time>[- :0-9]*) INFO.*DAGScheduler.*Job 0 finished')
r_complete = re.compile(r'\[(?P<epoch>[0-9]+)\] .* - .*Completion of .* test')

# Regex for fully-qualified Java class name https://stackoverflow.com/a/5205467/708883
r_exception = re.compile(r'(?P<cause>(Caused by: )?)(?P<package>[a-zA-Z_$][a-zA-Z\d_$]*\.)*(?P<class>[a-zA-Z_$][a-zA-Z\d_$]*Exception): (?P<message>.*)')
simple_regex_exception_messages = {
    # Driver pod's init container errors out. Cause TBD.
    'ETCD_NO_LEADER': re.compile(r'client: etcd member .* has no leader'),
    'BROKEN_PIPE': re.compile(r'Broken pipe'),
    'SPARK_ADMISSION_WEBHOOK': re.compile(r'failed calling admission webhook "webhook\.sparkoperator\.k8s\.io'),
    'REMOTE_CLOSED_CONNECTION': re.compile(r'Remote host closed connection'),
    'CONNECTION_RESET': re.compile(r'Connection reset'),
}

app = None
app_id = None

def spark_log_time_to_epoch(spark_time):
    """
    Convert time format of Spark logs to unix epoch (seconds)
    :param spark_time: UTC formatted e.g. 2019-05-15 00:31:56
    :return: unix epoch in seconds
    """
    return calendar.timegm(time.strptime(spark_time, "%Y-%m-%d %H:%M:%S"))


def compute_times(output, succeeded=False):
    """
    Calculates time intervals between events in provided output. Side effect: sets global app_id and app variables.
    :param output: Output from spark operator execution
    :param succeeded: Whether output represents a successful execution
    :return: (metric -> int (seconds) dictionary, regex -> epoch dictionary)
    """
    timings = {}  # interval name -> computed interval in seconds
    global app, app_id
    error_states = {'Terminating', 'Unknown', 'Error'}
    # The times are computed by using two regular expressions; one marks the start of the interval and
    # one marks the end of the interval.

    # interval name -> (start regex, end regex). This the blueprint of what is to be computed.
    time_regex = {
        TIMING_METRIC_NAME_DRIVER_POD_DETECTED: (r_app_created, r_driver_pod_creation_event),
        TIMING_METRIC_NAME_DRIVER_POD_PENDING_DELAY: (r_driver_pod_creation_event_pending, r_driver_pod_initializing),
        TIMING_METRIC_NAME_DRIVER_POD_INITIALIZATION: (r_driver_pod_initializing, r_driver_pod_running),
        TIMING_METRIC_NAME_DRIVER_APP_SUBMIT: (r_driver_pod_running, r_driver_context_app_submitted),
        TIMING_METRIC_NAME_DRIVER_APP_LOAD: (r_driver_context_app_submitted, r_driver_context_jar_added),
        TIMING_METRIC_NAME_EXECUTOR_WAIT_TOTAL: (r_exec_allocator, r_exec_registered_time),
        TIMING_METRIC_NAME_EXEC_POD_DETECTED: (r_exec_allocator, r_exec_pod_creation_event),
        TIMING_METRIC_NAME_EXEC_POD_PENDING_DELAY: (r_exec_pod_creation_event_pending, r_exec_pod_initializing),
        TIMING_METRIC_NAME_EXEC_POD_INITIALIZATION: (r_exec_pod_initializing, r_exec_pod_running),
        TIMING_METRIC_NAME_EXEC_REGISTRATION: (r_exec_pod_running, r_exec_registered_time),
        TIMING_METRIC_NAME_JOB_RUNTIME: (r_exec_registered_time, r_job_finished),
        TIMING_METRIC_NAME_CLEAN_UP: (r_job_finished, r_complete),
    }

    # regex -> (epoch, match). Time value found for each regex. Memoize because regexes are used multiple times.
    regex_results = {}
    for r1, r2 in time_regex.values():
        for r in [r1, r2]:
            if r not in regex_results:
                m = r.search(output)
                if m:
                    # Not all log lines express time in the same format, so need multiple conversion rules
                    # to get to epoch. Presume regex group names are standardized.
                    match_groups = m.groupdict()
                    if 'epoch' in match_groups:
                        regex_results[r] = int(match_groups['epoch'])
                    elif 'spark_time' in match_groups:
                        regex_results[r] = spark_log_time_to_epoch(match_groups['spark_time'])
                    else:
                        log("Bug: regex {} is supposed to extract times but has no recognized group names. Matched {}.".format(
                            r.pattern, m.group(0)))
                else:
                    # Record explicit failure ot match so we don't try this regex again
                    regex_results[r] = None

    # compute intervals now that we have found all the times.
    for interval_name, (r_start, r_end) in time_regex.iteritems():
        epoch_start = regex_results.get(r_start)
        epoch_end = regex_results.get(r_end)
        if epoch_start and epoch_end:
            timings[interval_name] = epoch_end - epoch_start

    # Identify app creation
    m_app_created = r_app_created.search(output)
    if m_app_created:
        app_id = m_app_created.group('app')
        if app_id:
            app = '-'.join(app_id.split('-')[0:-1])  # Assume app-name-uniqueid format

    if metrics_enabled:
        emit_timing_metrics(timings, succeeded)
    return (timings, regex_results)


def add_standard_tags(tags):
    if app_id:
        tags[TAG_APP_ID] = app_id
    if app:
        tags[TAG_APP] = app
    tags[TAG_ESTATE] = metric_context.pod
    tags[TAG_DC] = metric_context.datacenter
    return tags


def emit_timing_metrics(times, succeeded):
    tags = add_standard_tags({
        TIMING_METRIC_SUCCESS_TAG: "OK" if succeeded else "FAIL"
    })
    m_list = [
        Metric('sam.watchdog', ['cliChecker', 'SparkOperatorTest', 'Times', metric], seconds, int(time.time()), metric_context, tags)
        for metric, seconds in times.iteritems()]
    try:
        funnel_client.publish_batch(m_list)
    except Exception as e:
        logging.exception('Failed to send %d metrics to funnel' % len(m_list))


def analyze_helper(output, epochs):
    """
    Classifies failure in provided output
    :param output: output from failed spark operator execution
    :param epochs: dict(regex -> epoch) of when in the output notable events occurred. See compute_times
    :return: class (as string)
    """
    for code, regex in simple_regex_tests.iteritems():
        if regex.search(output):
            return code

    # Check for termination due to timeout.
    if r_timeout_running.search(output):
        if epochs.get(r_driver_pod_running):
            # Check for failures after the driver is running
            # This block digs into driver logs
            if epochs.get(r_driver_context_app_submitted):
                # Check for failure cases that occur after the application JAR has been loaded
                if epochs.get(r_driver_context_jar_added):
                    # Requesting executors is the next thing to do after adding the application JAR. Unknown why it sometimes doesn't happen.
                    if epochs.get(r_exec_allocator):
                        # Figure out when the executors were requested
                        if epochs.get(r_exec_allocator) - epochs.get(r_driver_pod_running) >= 180:
                            return "TIMEOUT_EXECUTOR_ALLOCATOR_LATE"
                        else:
                            if epochs.get(r_exec_pod_running):
                                # If we can't figure out a specific reason, look into what part was slow.

                                # We know that the executor pod started running but that we timed out before completing the job.
                                # In the happy case, it takes about 15 seconds for the executor to start and register itself. Logs:
                                # KubernetesClusterSchedulerBackend$KubernetesDriverEndpoint:54 - Registered executor NettyRpcEndpointRef(spark-client://Executor) (10.251.124.170:46644) with ID 1
                                # KubernetesClusterSchedulerBackend:54 - SchedulerBackend is ready for scheduling beginning after reached minRegisteredResourcesRatio: 0.8

                                # Conversely, if the executor startup was slow, then we see the Spark Driver log:
                                # KubernetesClusterSchedulerBackend:54 - SchedulerBackend is ready for scheduling beginning after waiting maxRegisteredResourcesWaitingTime: 30000(ms)
                                # (after which the driver just continues anyway), and then it logs:
                                # TaskSchedulerImpl:66 - Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient resources
                                # which repeats until the executors finally do show up.
                                # If the executors do start performing work after the timeout, then we have to infer it from the following in the driver logs:
                                # TaskSetManager:54 - Starting task 0.0 in stage 0.0 (TID 0, 10.251.124.170, executor 1, partition 0, PROCESS_LOCAL, 7878 bytes)

                                # In the happy case, it's ~25 seconds from requesting executors to work beginning.

                                # As a first pass, let's say that if the time from requesting executor to running executor
                                # pod exceeds 60s, then that is the cause of the test failure.

                                if epochs.get(r_exec_pod_running) - epochs.get(r_exec_allocator) >= 60:
                                    return "TIMEOUT_EXECUTOR_SLOW_POD_CREATION"
                                else:
                                    if epochs.get(r_exec_registered_time):
                                        # As a first pass, let's say that if the time from running executor to registered executor
                                        # exceeds 60s, then that is the cause of the test failure.
                                        if epochs.get(r_exec_registered_time) - epochs.get(r_exec_pod_running) >= 60:
                                            return "TIMEOUT_EXECUTOR_SLOW_REGISTRATION"
                                    # "UNKNOWN" because we haven't yet collected an example of this
                                    # Check for delay between pod running and driver logging task start, perhaps?
                                    return "UNKNOWN_TIMEOUT_EXECUTOR_RUNNING"
                            else:
                                # "UNKNOWN" because we haven't yet collected an example of this
                                return "UNKNOWN_TIMEOUT_EXECUTOR_NOT_RUNNING"
                    else:
                        return 'EXECUTOR_ALLOCATOR_DID_NOT_RUN'
                else:
                    # "UNKNOWN" because we haven't yet collected an example of this
                    return "UNKNOWN_TIMEOUT_DRIVER_CONTEXT_JAR_NOT_ADDED"
            else:
                # "UNKNOWN" because we haven't yet collected an example of this
                return "UNKNOWN_TIMEOUT_DRIVER_CONTEXT_NOT_SUBMITTED"
        else:
            return "UNRECOGNIZED_TIMEOUT_DRIVER_NOT_RUNNING"
    else:
        # Failure was *not* due to a timeout.
        if r_spark_submit_failed.search(output):
            return "SPARK_SUBMIT_FAILED"  # Exception classification will provide reason
        else:
            return "UNRECOGNIZED_NON_TIMEOUT"


def detect_exceptions(output):
    """
    Identifies noteworthy exceptions in provided output
    :param output: output from failed spark operator execution
    :return: class (as string)
    """
    exception = {}
    match_iterator = r_exception.finditer(output)
    # heuristic: assume that the first Exception is the most interesting, but if it has logged "Caused by" lines, use
    # the final reported cause. E.g. BazException is selected from the following:
    # FooException: foo
    #    ...
    # Caused by BarException: bar
    #    ...
    # Caused by BazException: baz
    #    ...
    # ...
    # QuuxException: quux
    #    ...
    # Caused by FnarfException: fnarf
    #    ...
    exception_match = None
    for m in match_iterator:
        if not exception_match:
            # First exception found is better than no exception
            exception_match = m
        elif m.group('cause'):
            # If this is a cause, prefer it over the previously found exception

            # Exception (ha!) to the rule: sometimes the cause is less specific. Don't prefer it in that case. E.g.
            # javax.net.ssl.SSLHandshakeException: Remote host closed connection during handshake
            # Caused by: java.io.EOFException: SSL peer shut down incorrectly
            # "Remote host closed connection" actually seems more useful.
            more_specific_than = {
                'SSLHandshakeException': 'EOFException',
                'SocketTimeoutException': 'SocketException',
            }
            if more_specific_than.get(exception_match.group('class'), 'NO_MATCH') == m.group('class'):
                continue
            else:
                exception_match = m
        else:
            # Otherwise we're done; subsequent exception blocks are probably just cascading errors
            break

    if exception_match:
        # Record the exception itself
        exception[EXCEPTION] = exception_match.group('class')
        # Record additional exception classification based on the message
        for code, regex in simple_regex_exception_messages.iteritems():
            if regex.search(exception_match.group('message')):
                exception[EXCEPTION_CAUSE] = code
    return exception


def analyze(output, epochs):
    """
    Classifies failure in provided output, identifies noteworthy exceptions, and emits metrics (if enabled)
    :param output: output from failed spark operator execution
    :param epochs: dict(regex -> epoch) of when in the output notable events occurred. See compute_times
    :return: class (as string)
    """
    analysis = {
        CLASSIFICATION: analyze_helper(output, epochs)
    }
    analysis.update(detect_exceptions(output))
    if metrics_enabled:
        emit_failure_analysis_metrics(analysis)
    return analysis


def emit_failure_analysis_metrics(analysis):
    # Although the GROUPBY magic as described in the example metric queries can work around optional tags, it seems
    # expedient to just always populate the tags to prevent Argus surprises in the future.
    tags = add_standard_tags(dict([(key, analysis.get(key, "None")) for key in ANALYSIS_KEYS]))
    m_list = [
        Metric('sam.watchdog', ['cliChecker', 'SparkOperatorTest', FAILURE_ANALYSIS_METRIC_NAME], 1, int(time.time()), metric_context, tags)
    ]
    try:
        funnel_client.publish_batch(m_list)
    except Exception as e:
        logging.exception('Failed to send %d metrics to funnel' % len(m_list))


def pretty_result(analysis):
    # Convert result to format used in the test files
    # Use bare classification if there is no additional info. Otherwise string representation of named tuple.
    return json.dumps(analysis, sort_keys=True) if len(analysis) > 1 else analysis[CLASSIFICATION]


def log(s):
    print('+++ [{}] {}'.format(THIS_SCRIPT, s))


if args.command:
    start = time.time()
    try:
        log("Executing and analyzing output of: {}".format(" ".join(additional_args)))
        print(subprocess.check_output(additional_args, stderr=subprocess.STDOUT), end='')
        timings, epochs = compute_times(subprocess.STDOUT, succeeded=True)
        log("Times: ")
        log("No errors ({}s)".format(int(time.time() - start)))
        sys.exit(0)
    except subprocess.CalledProcessError as e:
        print(e.output, end='')
        timings, epochs = compute_times(e.output)
        log("Analysis of failure [{}] ({}s): {}".format(
            e.returncode,
            int(time.time() - start),
            pretty_result(analyze(e.output, epochs))))
        log("Times: {}".format(json.dumps(timings, sort_keys=True)))
        sys.exit(e.returncode)
elif args.analyze:
    with open(args.analyze, 'r') as file:
        output = file.read()
        timings, epochs = compute_times(output)
        print(pretty_result(analyze(output, epochs)))
        print("Times: {}".format(json.dumps(timings, sort_keys=True)))
elif args.test_dir:
    success = True
    for filename in sorted(os.listdir(args.test_dir)):
        with open(os.path.join(args.test_dir, filename), 'r') as file:
            expect, output = file.read().split('\n', 1)
            timings, epochs = compute_times(output)
            text_result = pretty_result(analyze(output, epochs))
            if text_result == expect:
                print(u"\u2713 {}: {}".format(filename, expect).encode('utf-8'))
            else:
                print(u"\u2718 {}: {} expected, {} obtained".format(filename, expect, text_result).encode('utf-8'))
                success = True
            # Too much visual noise. But occasionally useful during development.
            # print("Times: {}".format(json.dumps(timings, sort_keys=True)))
    if not success:
        sys.exit(1)
else:
    log("Bug: argparse failed to set a known operation mode.")
    sys.exit(1)
