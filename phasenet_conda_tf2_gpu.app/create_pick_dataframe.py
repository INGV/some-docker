import json
import pandas as pd
from tqdm import tqdm


# Must be run inside the PHASENET-RESULT folder!!!

with open("picks.json") as IN:
    picks_json = json.load(IN)

print("DOCKER: Creating Picks Dataframe ...")
# {'id': 'NC.MCV..EH.0361339.npz', 'timestamp': '1970-01-01T00:01:30.150',
#  'prob': 0.9811667799949646, 'type': 'p'}
# {'id': 'NC.MCV..EH.0361339.npz', 'timestamp': '1970-01-01T00:00:59.990',
#  'prob': 0.9872905611991882, 'type': 'p'}

outdict = {}
for xx, ii in enumerate(tqdm(picks_json)):
    outdict[str(xx)] = {}
    outdict[str(xx)]["NETWORK"] = ii['id'].split(".")[0]
    outdict[str(xx)]["STATION"] = ii['id'].split(".")[1]
    # outdict[str(xx)]["LOCATION"] = ii['id'].split(".")[2]
    # outdict[str(xx)]["CHANNEL"] = ii['id'].split(".")[3]
    outdict[str(xx)]["PHASE"] = ii['type'].upper()
    outdict[str(xx)]["UTCDATETIME"] = ii['timestamp']
    outdict[str(xx)]["PROBABILITY"] = ii['prob']
    try:
        outdict[str(xx)]["AMPLITUDE"] = ii['amp']
    except KeyError:
        pass

df = pd.DataFrame.from_dict(outdict, orient='index')
df.to_csv("phasenet_picks_dataframe.csv",
          sep=',',
          index=False,
          # float_format="%.3f",
          na_rep="NA", encoding='utf-8')
