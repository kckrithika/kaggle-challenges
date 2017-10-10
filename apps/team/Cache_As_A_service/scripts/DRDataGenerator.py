import os

from Cluster import Cluster
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

from Kingdom import Kingdom
from Spod import Spod

configFileName = "metadata/config/ClsuterDetails.xls"

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


def queryPodtapData():
    pods = requests.get('https://podtap-dev.internal.salesforce.com/?format=json', verify=False).json()['pods']
    kingdoms = dict()
    drDetails = dict()

    allPodsDetails = os.path.join(metadata_dir, 'metadata/config/AllPodList.txt');
    allPodsDetailsFile = open(allPodsDetails,'w')

    for pod in pods:
        if pod['operational_status'] == 'active' and pod['build_type'] == 'released':
            kingdomName = pod['datacenter']
            spod = pod['superpod']
            clusterName = pod['name']

            if spod is None:
                spod = '*'
            allPodsDetailsFile.write(clusterName+','+spod.upper()+','+kingdomName.upper()+"\n")
            dr = pod['dr']
            if pod['dr']:
                if spod:
                    drDetails[clusterName] = kingdomName + "-" + spod
                else:
                    drDetails[clusterName] = kingdomName + "-" + "Unknown"
            else:
                #If DR entry already exist in drDetails then use them as well
                if clusterName in drDetails:
                    drKingdomSpod = drDetails[clusterName]
                    cluster = Cluster(clusterName, 0, 0, 0, 0, dr, drKingdomSpod.split('-')[0], drKingdomSpod.split('-')[1], None)
                    drDetails.pop(clusterName)
                else:
                    cluster = Cluster(clusterName, 0, 0, 0, 0, dr, None, None, None)

                if kingdoms.has_key(kingdomName):
                    kingdom = kingdoms.get(kingdomName)
                    spods = kingdom.getSpods()
                    if spods.has_key(spod):
                        spodObj = spods[spod]
                        clusters = spodObj.getClusters();

                        if clusters.has_key(clusterName):
                            print 'Error ' + clusterName + ' already in SPOD'
                        else:
                            clusters[clusterName] = cluster
                    else:
                        spodClusters = dict()
                        spodClusters[clusterName] = cluster
                        spodObj = Spod(spodClusters)
                        spods[spod] = spodObj
                else:
                    spods = dict()
                    spodClusters = dict()
                    spodClusters[clusterName] = cluster
                    spodObj = Spod(spodClusters)
                    spods[spod] = spodObj
                    kingdom = Kingdom(kingdomName, spods)
                    kingdoms[kingdomName] = kingdom

    allPodsDetailsFile.close()

    #Process the DR clusters
    for kingdomName in kingdoms:
        kingdom = kingdoms[kingdomName];
        spods = kingdom.getSpods();
        for spodName in spods:
            spod = spods[spodName];
            clusters = spod.getClusters();
            for clusterName in clusters:
                if clusterName in drDetails:
                    drKingdomSpod = drDetails[clusterName]
                    cluster = clusters[clusterName]
                    cluster.setDrKingdom(drKingdomSpod.split('-')[0])
                    cluster.setDrSpod(drKingdomSpod.split('-')[1])

    return kingdoms

def generateKingdomDetailsFile(kingdoms):
    kingdomDetailsFileName = os.path.join(metadata_dir, 'metadata/config/KingdomDetails.txt');
    kingdomDetailsFile = open(kingdomDetailsFileName,'w')

    kingdomDetailsFile.write('DC,SPOD,POD,DR-DC,DR-SPOD\n')
    for kingdomName, kingdomDetail in sorted(kingdoms.items()):
        spods = kingdomDetail.getSpods()
        for spodName, spodDetail in sorted(spods.items()):
            clusters = spodDetail.getClusters()
            for clusterName, clusterDetail in sorted(clusters.items()):
                kingdomDetailsFile.write(kingdomName + ',' + str(spodName) + ',' + clusterName \
                                   + ',' + str(clusterDetail.getDrKingdom()) + ',' + str(clusterDetail.getDrSpod()) + "\n")

    kingdomDetailsFile.close()

def checkForDR(kingdomsFromClusterDetails, drKingdom, drSpod, clusterName):
    exists = True

    if drKingdom not in kingdomsFromClusterDetails:
        exists = False
        return

    kingdom = kingdomsFromClusterDetails[drKingdom]
    spods = kingdom.getSpods()

    if drSpod not in spods:
        exists = False
        return

    spod = spods[drSpod]
    clusters = spod.getClusters()

    if clusterName not in clusters:
        exists = False
        return

    return exists


def reportMismatches(kingdomsFromPodTap, kingdomsFromClusterDetails ):
    mismatchReportFileName = os.path.join(metadata_dir, 'metadata/config/MismatchReport.txt');
    mismatchReportFile = open(mismatchReportFileName,'w')

    messages = dict()

    for kingdomName, kingdomDetailFromPt in sorted(kingdomsFromPodTap.items()):
        if kingdomName not in kingdomsFromClusterDetails:
            mismatchReportFile.write("ERROR: Kingdom " + kingdomName + " does not exist in Caas ClusterDetails\n")
            continue
        kingdom = kingdomsFromClusterDetails[kingdomName]
        spodsFromPt = kingdomDetailFromPt.getSpods()
        for spodName, spodDetailFromPt in sorted(spodsFromPt.items()):
            spodDetail = kingdom.getSpods()
            if spodName not in spodDetail:
                mismatchReportFile.write("ERROR: SPOD " + spodName + " does not exist in Caas ClusterDetails\n")
                continue

            spod = spodDetail[spodName]

            clustersFromPt = spodDetailFromPt.getClusters()
            clusters = spod.getClusters()

            for clusterName, clusterDetailFromPt in sorted(clustersFromPt.items()):
                defaultClusterName = "sp-" + clusterName + "-c1"
                if defaultClusterName not in clusters:
                    mismatchReportFile.write("ERROR: POD " + defaultClusterName + " does not exist in Caas ClusterDetails\n")
                else:
                    mismatchReportFile.write("POD " + defaultClusterName + " exist in Caas ClusterDetails\n")

                pcClusterName = "sp-" +  clusterName +"-pc1"
                if pcClusterName not in clusters:
                    mismatchReportFile.write("ERROR: POD " + pcClusterName + " does not exist in Caas ClusterDetails\n")
                else:
                    mismatchReportFile.write("POD " + pcClusterName + " exist in Caas ClusterDetails\n")

                #check for DR with Default cluster


                if not checkForDR(kingdomsFromClusterDetails, clusterDetailFromPt.getDrKingdom(), clusterDetailFromPt.getDrSpod(), defaultClusterName):
                    mismatchReportFile.write("ERROR: POD " + defaultClusterName + " does not exist in Caas ClusterDetails for DR\n")
                else:
                    mismatchReportFile.write("POD " + defaultClusterName + " exist in Caas ClusterDetails for DR\n")

                # check for DR with PC cluster

                if not checkForDR(kingdomsFromClusterDetails, clusterDetailFromPt.getDrKingdom(), clusterDetailFromPt.getDrSpod(),
                                  pcClusterName):
                    mismatchReportFile.write(
                        "ERROR: POD " + pcClusterName + " does not exist in Caas ClusterDetails for DR\n")
                else:
                    mismatchReportFile.write(
                        "POD " + pcClusterName + " exist in Caas ClusterDetails for DR\n")

    mismatchReportFile.close()


def main():
    kingdomsDetailFromPodTap = queryPodtapData()
    generateKingdomDetailsFile(kingdomsDetailFromPodTap)

    # load kingdom details
    kingdoms = getAllKingdoms(metadata_dir)
    reportMismatches(kingdomsDetailFromPodTap, kingdoms)
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
                    if drSpodAndDC is not None:
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