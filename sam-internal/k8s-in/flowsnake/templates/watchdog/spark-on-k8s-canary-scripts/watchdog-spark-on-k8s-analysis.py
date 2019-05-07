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

parser = ArgumentParser()
mode_group = parser.add_mutually_exclusive_group(required=True)
mode_group.add_argument("--command", action='store_true',
                    help="Spark Operator Watchdog script (and arguments) to execute")
mode_group.add_argument("--analyze", dest="analyze",
                    help="Process the provided static content rather than executing a script")
mode_group.add_argument("--test-dir", dest="test_dir",
                        help="Process all files in the provided directory as static content. First line of each file must be asserted result.")
args, additional_args = parser.parse_known_args()

simple_regex_tests = {
    # Not really sure what causes this or if we need to classify further.
    'DRIVER_INIT_ERROR': re.compile('Pod change detected.*-driver changed to Init:Error'),
    # Josh is working on restarting the scheduler when this is encountered.
    'SCHEDULER_ASSUME_POD': re.compile("FailedScheduling.*AssumePod failed: pod .* state wasn't initial but get assumed")
}
def analyze(combined_output):
    for code, regex in simple_regex_tests.iteritems():
        if regex.search(combined_output):
            return code
    return "UNRECOGNIZED"

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
