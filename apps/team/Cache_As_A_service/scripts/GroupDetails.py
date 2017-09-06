class GroupDetails(object):
    def __init__(self, kingdomName, spodName, clusterName ):
        self.kingdomName = kingdomName
        self.spodName = spodName
        self.clusterName = clusterName

    def getKingdomName(self):
        return self.kingdomName

    def getSpodName(self):
        return self.spodName

    def getClusterName(self):
        return self.clusterName
