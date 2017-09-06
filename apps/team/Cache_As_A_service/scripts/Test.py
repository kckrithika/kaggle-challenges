import requests
import urllib
from string import Template
from ConfigLoader import getKingdomDetails
from ConfigLoader import getConfiguration
import splunklib.client as client
import splunklib.results as splunkresults
from ConfigLoader import getConfigurationForGroup
import argparse
import getpass
from prettytable import PrettyTable
import progressbar
#
class textColors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

# import requests
# from requests.auth import HTTPDigestAuth
# import json
#
# # Replace with the correct URL
# url = "https://refocus-staging.internal.salesforce.com/v1/subjects"
#
# # data = {  "description": "ramtest1",
# #  "isPublished": True,
# #  "name": "ramtest1",
# #  "parentAbsolutePath": "t1.ct1"
# # }
# # data = {  "description": "CAAS",
# #  "isPublished": True,
# #  "name": "CAAS11",
# #  "parentAbsolutePath": "t1"
# # }
# import ast
#
#
# str ='data={"description":"par","isPublished":True,"name":"PAR","parentAbsolutePath":"CAAS"}'
# eval = ast.literal_eval(str)
#
#
# #response = requests.post(url, json=data, headers={'Authorization', ' XXXXXX ', 'Content-Type',
# #                                                  'application/json'})
#
# #print response
#
# req = urllib2.Request(url)
# req.add_header('Content-Type', 'application/json')
# req.add_header('Authorization', ' XXXXX ')
# req.add_header('method','PATCH')
# dataJson = json.dumps(str)
# response = urllib2.urlopen(req, json.dumps(data))
#
#
# print response



    #response = requests.post(url, json=data, headers={'Aut, horization': '', })
    # It is a good practice not to hardcode the credentials. So ask the user to enter credentials at runtime
    #myResponse = requests.get(url, headers={'Authorization':' XXXXXX '})
    # print (myResponse.status_code)
    #
    # # For successful API call, response code will be 200 (OK)
    # if (myResponse.ok):
    #
    #     # Loading the response data into a dict variable
    #     # json.loads takes in only binary or string variables so using content to fetch binary content
    #     # Loads (Load String) takes a Json file and converts into python data structure (dict or list, depending on JSON)
    #     jData = json.loads(myResponse.content)
    #
    #     print("The response contains {0} properties".format(len(jData)))
    #     print("\n")
    #     for key in jData:
    #         print key + " : " + jData[key]
    # else:
    #     # If response code is not ok (200), print the resulting http error code with description
    #     myResponse.raise_for_status()
    #

parser = argparse.ArgumentParser()
parser.add_argument('-user', action='store', dest='user_name', help='SSO Username')
parser.add_argument('-group_name', action='store', dest='group_name', help='Deployment Group name from Config file.')
parser.add_argument('-metadata_dir', action='store', dest='metadata_dir',
                    help='Path of the directory where metadata is present.')

arguments = parser.parse_args()

password = getpass.getpass('Enter SSO Password:')

group_name = arguments.group_name
metadata_dir = arguments.metadata_dir


splunkConnectionMsgStr = textColors.OKBLUE + 'Connection to Splunk API Server : ' + textColors.ENDC
configMap = getConfiguration(metadata_dir)
configMapForGrp = getConfigurationForGroup(configMap, 'phx-sp2')

splunkConnectionMsgStr = splunkConnectionMsgStr + textColors.OKGREEN + ' Succeeded' + textColors.ENDC
print splunkConnectionMsgStr

argusConnectionMsgStr = textColors.OKBLUE + 'Connection to Argus API Server  : ' + textColors.ENDC

# connect to argus
sessionObj = requests.session()
argusBaseURL = configMapForGrp['argusWSURL']
result = sessionObj.post(argusBaseURL +
                         configMapForGrp['authAPI'],
                         json={"username": 'rpragada', "password": password})
if result.status_code != 200:
    argusConnectionMsgStr = argusConnectionMsgStr + textColors.FAIL + ' Failed : Reason : ' + result.status_code + textColors.ENDC
    print argusConnectionMsgStr
    exit(0)
else:
    argusConnectionMsgStr = argusConnectionMsgStr + textColors.OKGREEN + ' Succeeded' + textColors.ENDC
    print argusConnectionMsgStr
    redisCountFromConfig = 4

    encodedQueryStr = urllib.quote_plus('FILL_CALCULATE(DOWNSAMPLE(-6m:caas.sp-ap3-c1.UKB.SP1.-:caas-sp-ap3-c1.Redis__Server__Count_99thPercentile{device=*}:avg, #5m-min#), #min#)')
    for ctr in range(1, 5000):
        jsonObj = sessionObj.get(argusBaseURL + configMapForGrp['metricsQueryAPI'] + encodedQueryStr).json()
        print jsonObj

        if len(jsonObj) != 0 and type(jsonObj) is list:
            redisCountValues = jsonObj[0]['datapoints']
            if redisCountValues.values()[0] == 3:
                redisCountStatus = textColors.OKGREEN + 'Matched : Count = ' + str(
                    3) + textColors.ENDC
                print redisCountStatus
            else:
                redisCountStatus = textColors.FAIL + 'Not Matched : Count = ' + str(
                    redisCountValues.values()[0]) + textColors.ENDC
                print redisCountStatus
        else:
            redisCountStatus = textColors.WARNING + 'Unknown : No data found' + textColors.ENDC
            print redisCountStatus
