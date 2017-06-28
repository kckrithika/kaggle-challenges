#!/usr/bin/env python

import os
import sys
import subprocess
from subprocess import Popen, PIPE, STDOUT
from Queue import Queue
from threading import Thread
import time

NUM_WORKER_THREADS = 10

class jsonnet_workitem:
    def __init__(self, kingdom, estate, jsonnet_file, output_dir):
        self.kingdom = kingdom
        self.estate = estate
        self.jsonnet_file = jsonnet_file
        self.output_dir = output_dir
        #print("("+kingdom+","+estate+","+jsonnet_file+")")

# Run a command.  First return is true for success, second return is stdout+stderr
def run_cmd(cmd):
    combined = cmd.strip()
    try:
        p = Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT, close_fds=True)
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

def delete_if_skip(filename):
    with open(filename) as f:
      lines = f.readlines()
      if lines[0].strip() == "\"SKIP\"":
          os.remove(filename)
          return True
    return False

# Provess one template
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

worl_queue = Queue()
result_queue = Queue()
error_queue = Queue()
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
        print("done="+ str(done) + ",failed=" + str(failed) + ",total=" + str(total) + " " + str(pair[0]) + ". CMD: " + pair[1])
        result_queue.task_done()

# A worker thread to process work items
def worker():
    while True:
        this_item = worl_queue.get()
        passed, msg = run_jsonnet(this_item)
        #print("MSG:"+msg)
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
def make_work_items(templates_dir, output_root_dir, control_estates):
    ret = []
    template_list = [os.path.join(dp, f) for dp, dn, filenames in os.walk(templates_dir) for f in filenames if os.path.splitext(f)[1] == '.jsonnet']
    for ce in control_estates:
        for template in template_list:
            kingdom, estate = ce.split("/")
            full_out_dir = os.path.join(output_root_dir, kingdom, estate)

            # Do this here so threads dont race as this is not atomic
            if not os.path.exists(full_out_dir):
                os.makedirs(full_out_dir)
            ret.append(jsonnet_workitem(kingdom, estate, template, full_out_dir))
    return ret

def main():
    
    if len(sys.argv) != 4:
        print("usage: parallel_run.py template_dir output_dir list_of_control_estates.txt")
        return
    template_dir = sys.argv[1]
    output_dir = sys.argv[2]
    control_estates_filename = sys.argv[3]

    # Read control estates
    control_estates = []
    with open(control_estates_filename) as f:
      for line in f.readlines():
          if not line.startswith("#"):
            control_estates.append(line.strip())

    work_items = make_work_items(template_dir, output_dir, control_estates)
    
    failures = run_all_work_items(work_items)

    end_time = time.clock()

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
    # We should never get here
    sys.exit(1)