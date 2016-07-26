import os

def get_apps(root):
  ret = []
  for root, subFolder, files in os.walk(root):
    for item in files:
      print root, subFolder, item
      if item.endswith("manifest.yaml"):
        ret.append(subFolder)
  return ret

print get_apps(".")
