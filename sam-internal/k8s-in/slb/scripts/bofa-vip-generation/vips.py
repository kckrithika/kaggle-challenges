import sys
import json
import re
import requests
import os

kingdom_dr_mapping = {'dfw':'phx', 'ia2':'ph2', 'iad':'ord', 'ord':'iad', 'ph2':'ia2', 'phx':'dfw'}
"""
Dict[string, string]: A mapping of kingdom to its disaster recovery kingdom
"""
environment_mapping = {'cs':'customer sandbox', 'p':'production'}
"""
Dict[string, string]: A mapping of shortened environment string to actual environment name
"""

def atoi(text):
    """Function to convert a string to integer
    
    Args:
        text (str): The string to be converted

    Returns:
        int: The equivalent integer
    """
    return int(text) if text.isdigit() else text

def natural_keys(text):
    """Function used to sort based on numbers in key

    The function extracts substring integers from the keys, and returns them as a list

    Args:
        text (list[str]): The list of keys

    Returns:
        list[int]: The list of corresponding substring integers
    """
    return [ atoi(c) for c in re.split(r'(\d+)', text) ]

def get_json_from_uri(uri_string):
    """Function to request data from a remote URI
  
    Args:
        uri_string (str): The path of remote host

    Returns:
        json: JSON object from the content of the result
    """
    json_string = requests.get(uri_string, verify= False).content
    json_obj = json.loads(json_string)
    return json_obj

def get_kingdom_pod_map(kingdoms, environment):
    """Function to return list of pods for each kingdom

    Args:
        kingdoms (list[str]): list of kingdom to get the pod for
        environment (str): The required environment

    Returns:
        Dict[str, list[str]]: Mapping of kingdom  to list of pods
    """
    kingdom_environment_pod_map = {}
    kingdom_pods_map = {}

    pods_information_json = get_json_from_uri("https://podtap.internal.salesforce.com/?format=json")

    for pod in pods_information_json['pods']:

        if pod['operational_status'] == "active":

            if (pod['datacenter'], pod['environment'], pod['dr']) not in kingdom_environment_pod_map:
                kingdom_environment_pod_map[(pod['datacenter'], pod['environment'], pod['dr'])]=[]

            kingdom_environment_pod_map[(pod['datacenter'], pod['environment'], pod['dr'])].append(pod['name'])

    for kingdom in kingdoms:
        pods_in_kingdom = kingdom_environment_pod_map[(kingdom, environment, True)] + kingdom_environment_pod_map[(kingdom, environment, False)] + kingdom_environment_pod_map[(kingdom_dr_mapping[kingdom], environment, True)]
        pods_in_kingdom = list(set(pods_in_kingdom))
        pods_in_kingdom.sort(key=natural_keys)
        kingdom_pods_map[kingdom] = pods_in_kingdom

    return kingdom_pods_map

def generateManifest(lbname_prefix, kingdom_dir_path, pods_in_kingdom, kingdom):
    """Function to generate vips file for list of pods

    Args:
        lbname_prefix (str): Prefix for the name of the lb
        kingdom_dir_path (str): The path to store the vips file
        pods_in_kingdom (list[str]): The list of pods in the given kingdom
    """
    manifest_list = []

   

    for pod in pods_in_kingdom:
        template_file = open('file.template')
        template_string = template_file.read()

        hosts_information_json = get_json_from_uri("https://podtap.internal.salesforce.com/hosts?pod=" + pod)

        hostnames = []

        for hosts_information in hosts_information_json['results']:
            if re.search("-(app\d*)-", hosts_information['host']):
                hostname_format = "    - " + hosts_information['host'] + ".ops.sfdc.net"
                new_hostname_format =  hostname_format.replace(str(kingdom_dr_mapping[kingdom]), str(kingdom))
               
                hostnames.append(new_hostname_format)
               

        formatted_hostnames = "\n".join(hostnames)
        


        if len(hostnames) > 0:
            manifest_list.append(template_string.format(lbname_prefix + pod, formatted_hostnames))

    formatted_manifest_string = "\n".join(manifest_list)

    if not os.path.exists(kingdom_dir_path):
        os.mkdir(kingdom_dir_path)

    manifest_file_path = os.path.join(kingdom_dir_path, "vips.yaml")
    manifest_file = open(manifest_file_path, "w")
    manifest_file.write(formatted_manifest_string)

def main():
    """The main function
    """
    kingdoms = sys.argv[1].lower().split(',')
    environment = environment_mapping[sys.argv[2].lower()]
    lbname_prefix = sys.argv[3]
    baseDir = sys.argv[4]

    kingdom_pods_map = get_kingdom_pod_map(kingdoms, environment)
    for kingdom in kingdom_pods_map:
        kingdom_dir_path = os.path.join(baseDir, kingdom)
        generateManifest(lbname_prefix, kingdom_dir_path, kingdom_pods_map[kingdom],  kingdom)

if __name__ == '__main__':
    main()
