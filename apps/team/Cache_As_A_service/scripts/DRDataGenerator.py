import os
from ConfigLoader import getKingdomDetails
from ConfigLoader import getAllKingdoms
from ConfigLoader import getConfiguration
from ConfigLoader import getConfigurationForGroup
from ConfigLoader import getClusterNamesForGroup
from string import Template
from DRSpodAndDC import DRSpodAndDC
import argparse
import json
import requests
from json import JSONEncoder
from sets import Set
configFileName = "metadata/config/CaaSSAMSPODConfiguration.xls";

parser = argparse.ArgumentParser()
parser.add_argument('-metadata_dir', action='store', dest='metadata_dir',
                    help='Path of the directory where metadata is present.')

arguments = parser.parse_args()
metadata_dir = arguments.metadata_dir


def getDRDCAndSpod( podName, pods):
    for pod in pods:
        if pod['name'] == podName.lower():
            if pod['dr'] and pod['operational_status'] == 'active' and pod['build_type'] == 'released':
                return DRSpodAndDC(pod['datacenter'], pod['superpod'])


def main():
    # load kingdom details
    kingdoms = getAllKingdoms(metadata_dir)
    kingdomData = []
    podNames = Set()

    drMapperFileName = os.path.join(metadata_dir, 'metadata/config/DRMapperFileName.txt');
    drMapperFile = open(drMapperFileName,'w')

    pods = requests.get('https://podtap-dev.internal.salesforce.com/?format=json', verify=False).json()['pods']
    for kingdomName, kingdomDetail in sorted(kingdoms.items()):
        spods = kingdomDetail.getSpods()
        spodData = []
        for spodName, spodDetail in sorted(spods.items()):
            clusters = spodDetail.getClusters()
            drMapperFile.write("----------------------- " + kingdomName + "/" + spodName + " Start -----------------------\n")
            for clusterName, clusterDetail in sorted(clusters.items()):
                podName = clusterName.split('-')[1]
                if( podName not in podNames):
                    podNames.add(podName)
                    drSpodAndDC = getDRDCAndSpod(podName, pods)
                    if drSpodAndDC.getSpodName() is None:
                        drSpodName = 'Unknown'
                    else:
                        drSpodName = drSpodAndDC.getSpodName()

                    drMapperFile.write(kingdomName + ',' + spodName + ',sp-' + podName \
                              + '-c1,' + drSpodAndDC.getDcName() + ',' + drSpodName+"\n")
                    drMapperFile.write(kingdomName + ',' + spodName + ',sp-' + podName \
                              + '-pc1,' + drSpodAndDC.getDcName() + ',' + drSpodName+"\n")
            drMapperFile.write("----------------------- " + kingdomName + "/" + spodName + " End -----------------------\n")

    drMapperFile.close()

main()