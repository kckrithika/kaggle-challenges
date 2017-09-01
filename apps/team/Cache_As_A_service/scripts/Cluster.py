class Cluster(object):
    def __init__(self, name, srvPort, mgmtPort, redisPort, redisCount, isDRDeployment, drKingdom, drSpod ):
        self.name = name
        self.srvPort = srvPort
        self.mgmtPort = mgmtPort
        self.rediPort = redisPort
        self.redisCount = redisCount
        self.isDRDeployment = isDRDeployment
        self.drKingdom = drKingdom
        self.drSpod = drSpod

    def getName(self):
        return self.name

    def getSrvPort(self):
        return self.srvPort

    def getMgmtPort(self):
        return self.mgmtPort

    def getRedisPort(self):
        return self.rediPort

    def getRedisCount(self):
        return self.redisCount

    def getIsDRDeployment(self):
        return self.isDRDeployment

    def getPodName(self):
        return self.name.split('-')[1]

    def setDrKingdom(self, drKingdom):
        self.drKingdom = drKingdom

    def setDrSpod(self, drSpod):
        self.drSpod = drSpod

    def getDrKingdom(self):
        return self.drKingdom

    def getDrSpod(self):
        return self.drSpod

    def __str__(self):
        return "Caas Cluster : name %s, srv port %s, mgmt port %s, redis port %s, redis count %s is DR deployment %s, DR Kingdom %s" \
               ", DR Spod %s" \
               (self.name, self.srvPort, self.mgmtPort, self.rediPort, self.redisCount, self.isDRDeployment
                , self.drKingdom, self.drSpod)