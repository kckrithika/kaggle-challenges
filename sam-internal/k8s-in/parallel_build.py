#!/usr/bin/env python

import os
import sys
import subprocess
from subprocess import Popen, PIPE, STDOUT
from queue import Queue
from threading import Thread

NUM_WORKER_THREADS = 10

# Info needed to process one jsonnet file for one estate
class jsonnet_workitem:
    def __init__(self, kingdom, estate, jsonnet_file, output_dir):
        self.kingdom = kingdom
        self.estate = estate
        self.jsonnet_file = jsonnet_file
        self.output_dir = output_dir

# Simple run command wrapper
# First return is true for success, second return is cmd+stdout+stderr
def run_cmd(cmd):
    combined = cmd.strip()
    try:
        d = dict(os.environ)
        p = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True, env = d)
        p.wait()
        stdout = p.stdout.read().decode()
        stderr = p.stdout.read().decode()
        if len(stdout)>0:
            combined += "\n" + stdout
        if len(stderr)>0:
            combined += "\n" + stderr
        if p.returncode == 0:
            return True, combined
        else:
            return False, combined
    except Exception as e:
        return False, combined + "\nException: " + str(e)

# For some apps we SKIP in template by writing "SKIP" to output file
# Remove the output file when this happenes
# Returns true if file is deleted
def delete_if_skip(filename):
    with open(filename) as f:
      lines = f.readlines()
      if lines[0].strip() == "\"SKIP\"":
          os.remove(filename)
          return True
    return False

# Process one jsonnet template
def run_jsonnet(item):
    appNameWithExt = os.path.basename(item.jsonnet_file)
    appName = os.path.splitext(appNameWithExt)[0]
    outfile = os.path.join(item.output_dir, appName + ".json")
    cmd = "./jsonnet/jsonnet"
    cmd += " -V kingdom=" + item.kingdom
    cmd += " -V estate=" + item.estate
    cmd += " -V template=" + appName
    cmd += " " + item.jsonnet_file
    cmd += " -o " + outfile
    cmd += " --jpath ."
    (passed, msg) = run_cmd(cmd)
    if passed:
        if delete_if_skip(outfile):
            return True, "Skipped " + outfile
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
def make_work_items(templates_dirs, output_root_dir, control_estates):
    ret = []
    for template_dir in templates_dirs:
      template_list = [os.path.join(dp, f) for dp, dn, filenames in os.walk(template_dir) for f in filenames if os.path.splitext(f)[1] == '.jsonnet']
      for ce in control_estates:
          for template in template_list:
              kingdom, estate = ce.split("/")
              full_out_dir = os.path.join(output_root_dir, kingdom, estate)

              # Do this here so threads dont race as this is not atomic
              if not os.path.exists(full_out_dir):
                  os.makedirs(full_out_dir)
              ret.append(jsonnet_workitem(kingdom, estate, template, full_out_dir))
    return ret

# Python does not ship with the yaml library by default, and we dont want to deal with dependencies in TNRP
# This is ugly right now, but it avoid an extra step each time we add a control estate.
def find_control_estates(pools_dir):
    all_control_estates = {}
    pool_files = [os.path.join(dp, f) for dp, dn, filenames in os.walk(pools_dir) for f in filenames if os.path.basename(f) == 'pool.yaml']
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

def main():
    # Process arguments
    if len(sys.argv) != 4:
        print("usage: parallel_run.py template_dir output_dir pools_dir")
        return
    template_dirs = sys.argv[1]
    output_dir = sys.argv[2]
    pools_dir = sys.argv[3]

    # Read control estates
    control_estates = find_control_estates(pools_dir)

    # Do the work
    work_items = make_work_items(template_dirs.split(","), output_dir, control_estates)
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
