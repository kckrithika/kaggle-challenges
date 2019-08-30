

This repository is used for generation of vips.yaml in the appropriate kingdoms by fetching information about VIPs 
from the podtap interface. 


## Steps to generate vips.yaml in various kingdoms
```
python3 vips.py <kingdom_names> <environment(cs(sandbox)/p(production))> <lbname_prefix> <path_of_destination_vips_folder>
```

Example
```
python3 vips.py phx,dfw,iad,ia2,ph2,ord cs org-test- /Users/shravya.srinivas/Downloads/vip-generation 
```
