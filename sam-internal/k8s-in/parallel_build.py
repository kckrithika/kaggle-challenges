#!/usr/bin/python2.7

import os
import fnmatch
import sys
import subprocess
import json
import argparse
from subprocess import Popen, PIPE, STDOUT
if sys.version_info >= (3,0):
    from queue import Queue
else:
    from Queue import Queue
from threading import Thread
import uuid

NUM_WORKER_THREADS = 10
MULTI_TEMP_DIR = "./multifile-temp/"

# Info needed to process a set of jsonnet file for one estate for one team
class jsonnet_workitem:
    def __init__(self, kingdom, estate, jsonnet_files, output_dir, team_dir, label_filter):
        self.kingdom = kingdom
        self.estate = estate
        self.jsonnet_files = jsonnet_files
        self.output_dir = output_dir
        self.team_dir = team_dir
        self.label_filter = label_filter

# Simple run command wrapper
# First return is true for success, second return is cmd+stdout+stderr
def run_cmd(cmd):
    combined = cmd.strip()
    try:
        d = dict(os.environ)
        p = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True, env = d)
        stdout, stderr = p.communicate()
        if stdout and len(stdout)>0:
            combined += "\n" + stdout
        if stderr and len(stderr)>0:
            combined += "\n" + stderr
        if p.returncode == 0:
            return True, combined
        else:
            return False, combined
    except Exception as e:
        return False, combined + "\nException: " + str(e)

def matchAnyLabel(labels, matchLabels):
    for key in labels:
        if key in matchLabels and labels[key] == matchLabels[key]:
            return True
    return False

# For some apps we SKIP in template by writing "SKIP" to output file
# For some apps we SKIP in template when metadata label not matching any of the given labels if given label is not empty
# Remove the output file when this happens
# Returns true if file is deleted
def delete_if_skip(filename, matchLabels):
    with open(filename) as f:
        lines = f.readlines()
        if lines[0].strip() == "\"SKIP\"":
            os.remove(filename)
            return True

        f.seek(0)
        if len(matchLabels) > 0:
            fj = json.load(f)
            try:
                labels = fj["metadata"]["labels"]
                if not matchAnyLabel(labels, matchLabels):
                    os.remove(filename)
                    return True
            except KeyError:
                os.remove(filename)
                return True
    return False

def make_multifile(item):
    computed_out_files = []
    # Jsonnet multi-file input format is:
    #
    # {
    #   "sam-deployment-portal.json" : import ("sam/templates/sam-deployment-portal.jsonnet"),
    #   "samcontrol.json" : import ("sam/templates/samcontrol.jsonnet"),
    #   ...
    # }
    # We use a different multi-file for each estate and team combination (because these both influce arguments, and arguments are shared for all the multifile)
    # Estate and kingdom are passed on cmd line with '-V kingdom=xxx -V estate=yyy' and each team has a different include folder passed with `--jpath`
    multifilename = os.path.join(MULTI_TEMP_DIR, "multi_"+item.kingdom+"_"+item.estate+"_" + item.team_dir + "_" + str(uuid.uuid1()) + ".jsonnet")
    with open(multifilename, 'w') as multifile:
        multifile.write("{\n")
        for inFile in item.jsonnet_files:
            # Outfile is computed from infile, but with file extension changed from jsonnet to json
            appNameWithExt = os.path.basename(inFile)
            appName = os.path.splitext(appNameWithExt)[0]
            outfile = appName + ".json"
            multifile.write("  \"" + outfile + "\": (import \"" + inFile + "\"),\n")
            computed_out_files.append(os.path.join(item.output_dir, outfile))
        multifile.write("}\n")
    return multifilename, computed_out_files

# Process one work item (a set of json templates for same estate+team)
def run_jsonnet(item):
    multifilename, computed_out_files = make_multifile(item)

    includeDir = "./" + item.team_dir
    cmd = "./jsonnet/jsonnet"
    cmd += " -V kingdom=" + item.kingdom
    cmd += " -V estate=" + item.estate
    cmd += " " + multifilename
    cmd += " -m " + item.output_dir
    cmd += " --jpath . "
    cmd += " --jpath " + includeDir
    (passed, msg) = run_cmd(cmd)

    if passed:
        for outfile in computed_out_files:
            delete_if_skip(outfile, item.label_filter)
    return (passed, msg)

# Thread safe queues
worl_queue = Queue()
result_queue = Queue()
error_queue = Queue()

# Show total for better progress output
total = 0

# Show progress on stdout
def progress():
    global total
    done = 0
    failed = 0
    while True:
        pair = result_queue.get()
        if not pair[0]:
            failed += 1
            error_queue.put(pair[1])
        done += 1
        print("done="+ str(done) + ",total=" + str(total) + ",failed=" + str(failed) + " " + str(pair[0]) + ". CMD: " + pair[1])
        result_queue.task_done()

# A worker thread to process work items
def worker():
    while True:
        this_item = worl_queue.get()
        passed, msg = run_jsonnet(this_item)
        result_queue.put( (passed,msg) )
        worl_queue.task_done()

# Run work items in parallel
# Returns list of errors
def run_all_work_items(work_item_list):
    global total
    total = len(work_item_list)
    print("Starting " + str(NUM_WORKER_THREADS) + " workers")
    progress_thread = Thread(target=progress)
    progress_thread.daemon = True
    progress_thread.start()

    for i in range(NUM_WORKER_THREADS):
        t = Thread(target=worker)
        t.daemon = True
        t.start()

    for item in work_item_list:
        worl_queue.put(item)

    print("Waiting for work to finish")
    worl_queue.join()
    result_queue.join()
    print("Done")

    ret = []
    for i in range(0, error_queue.qsize()):
        ret.append(error_queue.get())
    return ret

# Returns a list of jsonnet_workitem
def make_work_items(templates_args, output_root_dir, control_estates, label_filter_map):
    ret = []
    for template_arg in templates_args:
      control_estates_for_template = control_estates
      project_estate_file = os.path.join(template_arg, "estate-filter.json")
      if os.path.isfile(project_estate_file):
          project_estates = json.load(open(project_estate_file))["kingdomEstates"]
          control_estates_for_template = list(filter_estates(project_estates, control_estates_for_template))
      if os.path.isdir(template_arg):
          template_list = [os.path.join(dp, f) for dp, dn, filenames in os.walk(template_arg) for f in filenames if os.path.splitext(f)[1] == '.jsonnet']
      elif os.path.isfile(template_arg):
          template_list = [template_arg]
      else:
          template_list = []

      for ce in control_estates_for_template:
            kingdom, estate = ce.split("/")
            full_out_dir = os.path.join(output_root_dir, kingdom, estate)

            # Do this here so threads dont race as this is not atomic
            if not os.path.exists(full_out_dir):
                os.makedirs(full_out_dir)

            # We need a different work item for each team, because they have different includes and we dont want conflicts
            mapTeamToFiles = {}

            for thisTemplate in template_list:
                teamDir = thisTemplate.split("/")[0]
                if not (teamDir in mapTeamToFiles):
                    mapTeamToFiles[teamDir] = []
                mapTeamToFiles[teamDir].append(thisTemplate)

            for (team, files) in mapTeamToFiles.items():
                required_labels = {}
                if ce in label_filter_map:
                    required_labels = label_filter_map[ce]
                ret.append(jsonnet_workitem(kingdom, estate, files, full_out_dir, team, required_labels))
    return ret

# Python does not ship with the yaml library by default, and we dont want to deal with dependencies in TNRP
# This is ugly right now, but it avoid an extra step each time we add a control estate.
def find_control_estates(pools_arg):
    all_control_estates = {}
    pool_files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(pools_arg) for f in filenames if os.path.basename(f) == 'pool.yaml']
    for pool_file in pool_files:
        with open(pool_file, 'r') as poolfd:
            lines = poolfd.readlines()
            this_ce = ""
            for line in lines:
                if line.strip().startswith("controlEstate:"):
                    if this_ce != "":
                        raise IOError("More than one controlEstate entry in " + pool_file)
                    this_ce = line.split(":")[1].strip()
            if this_ce == "":
                raise IOError("Could not find controlEstate in " + pool_file)
            all_control_estates[this_ce] = 1
    ret = []
    for ce in all_control_estates.keys():
        ret.append(ce)
    sorted(ret)
    return ret

def filter_estates(estates, filters):
    for e in estates:
        for f in filters:
            if fnmatch.fnmatch(e, f):
                yield e

def main():
    if sys.version_info[0] != 2:
      print("This script requires python 2")
      sys.exit(1)

    # Process arguments
    parser = argparse.ArgumentParser(description='Run jsonnet in parallel to build control estates templates')
    parser.add_argument('--src', help='One or more directories or filenames comma seperated', required=True)
    parser.add_argument('--out', help='Single output directory', required=True)
    parser.add_argument('--pools', help='Directory with structure of sam-internals/pools/ or a filename with json content', required=True)
    parser.add_argument('--estatefilter', help='Filter estates for local purposes only.  Supports a comma-seperated list of kingdom/estate.  Example: "prd/prd-samtest,prd-samdev"')
    parser.add_argument('--labelfilterfile', help='File containing label filters per estate, used to limit the set of files built for a location.')
    args = parser.parse_args()

    template_dirs = args.src
    output_dir = args.out
    pools_arg = args.pools
    estate_filter = []
    if args.estatefilter != None and len(args.estatefilter)>0:
      estate_filter = args.estatefilter.split(",")
      for this_filter in estate_filter:
        if len(this_filter.split("/")) > 2:
          print("Estate filter expected to be in format 'kingdom/estate' or '*somesubstring*' but got " + this_filter)
          sys.exit(1)

    # Write temp files in CWD because they can be useful for debugging (we use gitignore)
    # We do this here because we dont want to do it in the multi-threaded code and have conflicts
    if not os.path.exists(MULTI_TEMP_DIR):
        os.makedirs(MULTI_TEMP_DIR)

    # Read control estates
    if os.path.isdir(pools_arg):
        control_estates = find_control_estates(pools_arg)
    elif os.path.isfile(pools_arg):
        control_estates = json.load(open(pools_arg))["kingdomEstates"]
    else:
        print("\nwrong input,input have to be a filename or directory name.")
        sys.exit(1)

    if len(estate_filter)>0:
        control_estates = list(filter_estates(control_estates, estate_filter))
        print("Filter matched the following estates: " + str(control_estates))

    # In some locations we want only a few output files.  This can be done with "SKIP" but when you want 3 files out of 80 its
    # a hassle to add if statements to all the ones you dont want.  This filter approach works on a config file that specifies
    # required k8s labels for output files targeting a specific kingdon/estate.  File looks like this:
    #
    # [
    #  {
    #    "kingdomEstateMatch": "gcp-*/*",
    #    "requiredLabelValues": { "pcn": "deploy" }
    #  }
    # ]
    #
    # In this example, any kingdom starting with "gcp-" will only produce output k8s files with kubernetes label "pcn" and value "deploy"

    labelfilterlist = []
    if args.labelfilterfile != None and len(args.labelfilterfile)>0:
        labelfilterlist = json.load(open(args.labelfilterfile))
    labelfiltermap = {}
    for ce in control_estates:
        for filterentry in labelfilterlist:
            if fnmatch.fnmatch(ce, filterentry["kingdomEstateMatch"]):
                labelfiltermap[ce] = filterentry["requiredLabelValues"]

    # Do the work
    work_items = make_work_items(template_dirs.split(","), output_dir, control_estates, labelfiltermap)
    failures = run_all_work_items(work_items)

    # Report results
    if len(failures) == 0:
        print("Run successful")
        sys.exit(0)
    else:
        print("Run failed with errors:")
        for e in failures:
            print("ERROR: " + e)
        sys.exit(1)

if __name__ == "__main__":
    main()
    # We should never get here.  Return error just in case
    sys.exit(1)