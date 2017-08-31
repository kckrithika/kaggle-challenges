from Kingdom import Kingdom
from Spod import Spod
from Cluster import Cluster
from xlrd import open_workbook
import os

configFileName = "metadata/config/Configuration.xls"
clusterDetailsFileName = "metadata/config/ClusterDetails.xls"

def getConfiguration(metaDataDir):
    configFile = os.path.join(metaDataDir, configFileName);
    book = open_workbook(configFile);
    sheet = book.sheet_by_name('config')

    configDict = {}
    for row_index in xrange(1, sheet.nrows):
        for col_index in xrange(sheet.ncols):
            groupName = sheet.cell(row_index, 0).value;
            parameter = sheet.cell(row_index, 1).value;
            value = sheet.cell(row_index, 2).value;
            if configDict.has_key(groupName):
                paramValDict = configDict[groupName]
                paramValDict[parameter] = value
            else:
                paramValDict = dict()
                paramValDict[parameter] = value
                configDict[groupName] = paramValDict
    return configDict

def getConfigurationForGroup(configuration, groupName):
    paramValDict = dict()

    #Put default parameters first and the override with
    #the group specific paramater
    paramValDictForDefault = configuration['default']
    for k,v in paramValDictForDefault.items():
        paramValDict[k] = v

    if configuration.has_key(groupName):
        paramValDictForGroup = configuration[groupName]

        for k,v in paramValDictForGroup.items():
            paramValDict[k] = v
    return paramValDict


def getClusterNamesForGroup(metaDataDir, groupName):
    configFile = os.path.join(metaDataDir, clusterDetailsFileName);

    book = open_workbook(configFile);
    sheet = book.sheet_by_name(groupName)

    clusterNames = set()

    header = [sheet.cell(0, col_index).value for col_index in xrange(sheet.ncols)]
    for row_index in xrange(1, sheet.nrows):
        for col_index in xrange(sheet.ncols):
            #Get the 3rd column which is clusterName
            clusterName = sheet.cell(row_index, 2).value
            clusterNames.add(clusterName)

    return clusterNames


def getAllKingdoms(metaDataDir):
    configDict = getConfiguration(metaDataDir)
    kingdomSpodSheets = configDict['default']['kidngdomspodsheets'].split(",")
    kingdoms = dict()
    for kingdomSpodSheetName in kingdomSpodSheets:
        kingdoms = getKingdomDetails(metaDataDir, kingdomSpodSheetName, kingdoms)
    return kingdoms

def getKingdomDetails(metaDataDir, kingdomSpodSheetName, kingdoms):
    configFile = os.path.join(metaDataDir, clusterDetailsFileName)

    book = open_workbook(configFile);
    sheet = book.sheet_by_name(kingdomSpodSheetName)

    header = [sheet.cell(0, col_index).value for col_index in xrange(sheet.ncols)]
    for row_index in xrange(1, sheet.nrows):
        for col_index in xrange(sheet.ncols):
            kingdomName = sheet.cell(row_index, 0).value
            spod = sheet.cell(row_index, 1).value
            clusterName = sheet.cell(row_index, 2).value
            srvPort = int(sheet.cell(row_index, 3).value)
            mgmtPort = int(sheet.cell(row_index, 4).value)
            redisPort = int(sheet.cell(row_index, 5).value)
            redisCount = int(sheet.cell(row_index, 6).value)
            isDRDeployment = sheet.cell(row_index, 7).value
            drKingdom = sheet.cell(row_index, 8).value
            drSpod = sheet.cell(row_index, 9).value

        cluster = Cluster(clusterName, srvPort, mgmtPort, redisPort, redisCount, isDRDeployment,
                          drKingdom, drSpod)

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

    return kingdoms
