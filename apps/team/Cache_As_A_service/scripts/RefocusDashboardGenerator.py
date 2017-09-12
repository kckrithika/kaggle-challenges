import urllib2
import json
import argparse
import os
from ConfigLoader import getAllKingdoms
from string import Template
import ast

url = "https://refocus.internal.salesforce.com/v1/subjects"
parser = argparse.ArgumentParser()
parser.add_argument('-metadata_dir', action='store', dest='metadata_dir',
                    help='Path of the directory where metadata is present.')
parser.add_argument('-output_dir', action='store', dest='output_dir',
                    help='Path of the directory where manifest will be generated.')
parser.add_argument('-auth_token', action='store', dest='auth_token',
                    help='Auth Token for refocus.')
parser.add_argument('-generate_only_config', action='store_false', dest='generate_only_config',
                    help='Generate only refocus pyplyn config')


arguments = parser.parse_args()
metadata_dir = arguments.metadata_dir
output_dir = arguments.output_dir
auth_token = arguments.auth_token
generate_only_config = arguments.generate_only_config

def loadTemplates():
    refocusSubjectsTemplateFileName = "metadata/templates/refocus-subjects.yaml";
    refocusSubjectsTemplateFilePath = os.path.join(metadata_dir, refocusSubjectsTemplateFileName);
    refocusSubjectsTemplateFile = open(refocusSubjectsTemplateFilePath, "r");
    loadTemplates.refocusSubjectsTemplate = Template(refocusSubjectsTemplateFile.read());

    refocusExpressionTemplateFileName = "metadata/templates/refocus-expression.yaml";
    refocusExpressionTemplateFilePath = os.path.join(metadata_dir, refocusExpressionTemplateFileName);
    refocusSubjectsTemplateFile = open(refocusExpressionTemplateFilePath, "r");
    loadTemplates.refocusExpressionTemplate = Template(refocusSubjectsTemplateFile.read());

def createSubject(subjectJson):
    if not generate_only_config:
        try:
            subjectJson = ast.literal_eval(subjectJson)
            jsonVal = json.dumps(subjectJson)
            req = urllib2.Request(url)
            req.add_header('Content-Type', 'application/json')
            req.add_header('Authorization', auth_token)
            req.add_header('method', 'POST')
            response = urllib2.urlopen(req, jsonVal)
            print response
        except Exception as ex:
            print "Failed with exception " + ex.message + " for while processing : " + str(subjectJson)
        else:
            print "Success"



def getRefocusSubjectJson(name, description, path):
    clusterTemplateSubstitute = {'Description': description,
                                 'Published': True,
                                 'Name': name.upper(),
                                 'ParentAbsolutePath': path.upper()
                                 }
    return loadTemplates.refocusSubjectsTemplate.substitute(clusterTemplateSubstitute)

def getRefocusExpresion(root, kingdom, spod, clusterName, redisCount):
    warning = int(redisCount)-1
    critical = int(redisCount)-2
    expressionSubstitute = {'ClusterName': clusterName.lower(),
                                 'Kingdom': kingdom.upper(),
                                 'Root': root.upper(),
                                 'Spod': spod.upper(),
                                 'UpperClusterName': clusterName.upper(),
                                 'Warning': warning,
                                 'Critical': critical,
                                 'defaultValue': int(redisCount),

                                 }
    return loadTemplates.refocusExpressionTemplate.substitute(expressionSubstitute)

def createExpressionFile(baseName, kingdomName, spodName, clusterName, redisCount):
    refocusExpression = getRefocusExpresion(baseName, kingdomName, spodName, clusterName, redisCount)
    fileName = os.path.join(output_dir, "configuration-"+kingdomName+"-"+spodName+"-"+clusterName+".json");
    outputFile = open(fileName, 'w');

    outputFile.write(refocusExpression);
    outputFile.close();


def createRefocusDashboard():
    loadTemplates()
    kingdoms = getAllKingdoms(metadata_dir)
    baseName = 'CAAS'
    data = getRefocusSubjectJson(baseName, baseName, "")
    createSubject(data)

    for kingdomName in kingdoms:
        if kingdomName != 'prd':  #Ignore internal enviorment
            kingdom = kingdoms[kingdomName];
            data = getRefocusSubjectJson(kingdomName, kingdomName, baseName)
            createSubject(data)
            spods = kingdom.getSpods();
            for spodName in spods:
                spod = spods[spodName]
                data = getRefocusSubjectJson(spodName, spodName, baseName + "." + kingdomName)
                createSubject(data)
                clusters = spod.getClusters();
                for clusterName in clusters:
                    cluster = clusters[clusterName]
                    description = cluster.getDescription()
                    redisCount = cluster.getRedisCount()

                    if not description:
                        description = clusterName.upper()
                    parentAbsolutePath = baseName + "." + kingdomName + "." + spodName
                    data = getRefocusSubjectJson(clusterName, description, parentAbsolutePath)
                    createSubject(data)

                    createExpressionFile(baseName, kingdomName, spodName, clusterName, redisCount)


def main():
    createRefocusDashboard()

main()
