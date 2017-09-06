import requests
import urllib
from string import Template
from ConfigLoader import getKingdomDetails
from ConfigLoader import getConfiguration
from ConfigLoader import getAllKingdoms
from ConfigLoader import getGroupDetails
import splunklib.client as client
import splunklib.results as splunkresults
from ConfigLoader import getConfigurationForGroup
import argparse
import getpass
from prettytable import PrettyTable
import progressbar

class textColors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'

parser = argparse.ArgumentParser()
parser.add_argument('-user', action='store', dest='user_name', help='SSO Username')
parser.add_argument('-group_name', action='store', dest='group_name', help='Deployment Group name from Config file.')
parser.add_argument('-metadata_dir', action='store', dest='metadata_dir',
                    help='Path of the directory where metadata files are present.')

arguments = parser.parse_args()

password = getpass.getpass('Enter SSO Password:')
user = arguments.user_name
group_name = arguments.group_name
metadata_dir = arguments.metadata_dir

print textColors.BOLD + '****************************************************************' + textColors.ENDC
print textColors.BOLD + '********* Validating Deployment for Group ' + group_name + ' *************' + textColors.ENDC
print textColors.BOLD + '*****************************************************************' + textColors.ENDC

splunkConnectionMsgStr = textColors.OKBLUE + 'Connection to Splunk API Server : ' + textColors.ENDC
configMap = getConfiguration(metadata_dir)
configMapForGrp = getConfigurationForGroup(configMap, group_name)

try:
    splunkService = client.connect(
        host=configMapForGrp['splunkHost'],
        port=int(configMapForGrp['splunkPort']),
        username=user,
        password=password)
except Exception as e:
    splunkConnectionMsgStr = splunkConnectionMsgStr + textColors.FAIL + ' Failed : Reason : ' + e.message + textColors.ENDC
    print splunkConnectionMsgStr
    exit(0)

splunkConnectionMsgStr = splunkConnectionMsgStr + textColors.OKGREEN + ' Succeeded' + textColors.ENDC
print splunkConnectionMsgStr

argusConnectionMsgStr = textColors.OKBLUE + 'Connection to Argus API Server  : ' + textColors.ENDC

# connect to argus
sessionObj = requests.session()
argusBaseURL = configMapForGrp['argusWSURL']
result = sessionObj.post(argusBaseURL +
                         configMapForGrp['authAPI'],
                         json={"username": user, "password": password})
if result.status_code != 200:
    argusConnectionMsgStr = argusConnectionMsgStr + textColors.FAIL + ' Failed : Reason : ' + result.status_code + textColors.ENDC
    print argusConnectionMsgStr
    exit(0)
else:
    argusConnectionMsgStr = argusConnectionMsgStr + textColors.OKGREEN + ' Succeeded' + textColors.ENDC
    print argusConnectionMsgStr

print textColors.OKBLUE + '*********** Deployment Validations in progress *****************' + textColors.ENDC
table = PrettyTable(
    [textColors.BOLD + 'Kingdom', 'SPOD', 'Cluster', 'Redis Count Check', 'Version Check' + textColors.ENDC])

# load kingdom details
kingdoms = getAllKingdoms(metadata_dir)
groupDetails = getGroupDetails(metadata_dir, group_name)
clusterCount = len(groupDetails)

count = 0
bar = progressbar.ProgressBar(maxval=clusterCount, \
    widgets=[progressbar.Bar('=', '[', ']'), ' ', progressbar.Percentage()])
bar.start()

for groupDetail in groupDetails:
    kingdomName = groupDetail.getKingdomName()
    spodName = groupDetail.getSpodName()
    clusterName = groupDetail.getClusterName()

    kingdom = kingdoms[kingdomName]
    spods = kingdom.getSpods()
    spod = spods[spodName]
    clusters = spod.getClusters()

    cluster = clusters[clusterName]
    redisCountFromConfig = cluster.getRedisCount()
    dottedClusterName = clusterName
    dottedClusterName = dottedClusterName.replace('-', '*')

    substitutes = {'ClusterName': clusterName,
                   'ClusterDottedName': dottedClusterName,
                   'DC': kingdomName.upper(),
                   'SPOD': spodName.upper()}

    templateQuery = Template(configMapForGrp['query'])
    actualQueryStr = templateQuery.substitute(substitutes)
    encodedQueryStr = urllib.quote_plus(actualQueryStr)
    jsonObj = sessionObj.get(argusBaseURL + configMapForGrp['metricsQueryAPI'] + encodedQueryStr).json()

    if len(jsonObj) != 0 and type(jsonObj) is list:
        redisCountValues = jsonObj[0]['datapoints']
        if redisCountValues.values()[0] == redisCountFromConfig:
            redisCountStatus = textColors.OKGREEN + 'Matched : Count = ' + str(
                redisCountFromConfig) + textColors.ENDC
        else:
            redisCountStatus = textColors.FAIL + 'Not Matched : Count = ' + str(
                redisCountValues.values()[0]) + textColors.ENDC
    else:
        redisCountStatus = textColors.WARNING + 'Unknown : No data found' + textColors.ENDC

    kwargsExport = {"earliest_time": "-" + configMapForGrp['splunkQueryEarliestTime'],
                     "latest_time": configMapForGrp['splunkQueryLatestTime']}
    splunkQueryTemplate = Template(configMapForGrp['spunkQuery'])
    querySubstitutes = {'ClusterName': clusterName}
    queryExport = splunkQueryTemplate.substitute(querySubstitutes)
    exportsearchResults = splunkService.jobs.oneshot(queryExport, **kwargsExport)

    versionCheckStatus = ''
    if exportsearchResults.empty:
        versionCheckStatus = textColors.FAIL + 'Unknown : No data found' + textColors.ENDC

    dataNotFoundInSplunk = True
    results = splunkresults.ResultsReader(exportsearchResults)
    if not results:
        versionCheckStatus = textColors.WARNING + 'Unknown : No data found' + textColors.ENDC
    else:
        for result in results:
            dataNotFoundInSplunk = False
            event = result.popitem()
            versionFromLog = str(event[1]).rsplit(':', 1)[1].strip()
            if configMapForGrp['version'] == versionFromLog:
                versionCheckStatus = textColors.OKGREEN + 'Success : ' + versionFromLog + textColors.ENDC
            else:
                versionCheckStatus = textColors.FAIL + 'Failed : ' + versionFromLog + textColors.ENDC

    if dataNotFoundInSplunk:
        versionCheckStatus = textColors.WARNING + 'Unknown : No data found' + textColors.ENDC

    table.add_row([textColors.OKBLUE + kingdomName, spodName, clusterName + textColors.ENDC, redisCountStatus,
                   versionCheckStatus])

    count = count + 1
    bar.update(count)
bar.finish()
print table
