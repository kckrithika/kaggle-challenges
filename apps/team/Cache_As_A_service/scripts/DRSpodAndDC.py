class DRSpodAndDC(object):
    def __init__(self, dcName, spodName ):
        self.dcName = dcName
        self.spodName = spodName

    def getDcName(self):
        return self.dcName

    def getSpodName(self):
        return self.spodName

    def __unicode__(self):
        return unicode(self.some_field) or u''