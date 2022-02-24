#!/usr/bin/env python

"""
Extracted from  https://github.com/wayneweiqiang/PhaseNet/blob/master/demo/demo-obspy.ipynb
"""

import os
import obspy
from obspy import UTCDateTime
from obspy.clients.fdsn import Client

#
client = Client("SCEDC")
data_dir = "mseed"
if not os.path.exists(data_dir):
  os.makedirs(data_dir)
#
starttime = UTCDateTime("2019-07-04T17:00:00")
endtime = UTCDateTime("2019-07-05T00:00:00")
#
print("getting waveforms")
CCC = client.get_waveforms("CI", "CCC", "*", "HHE,HHN,HHZ", starttime, endtime)
CLC = client.get_waveforms("CI", "CLC", "*", "HHE,HHN,HHZ", starttime, endtime)
#
print("storing")
CCC.write(os.path.join(data_dir, "CCC.mseed"))
CLC.write(os.path.join(data_dir, "CLC.mseed"))
#
with open("fname.csv", 'w') as fp:
  fp.write("fname,E,N,Z\n")
  fp.write("CCC.mseed,HHE,HHN,HHZ\n")
  fp.write("CLC.mseed,HHE,HHN,HHZ\n")


"""
python run.py --mode=pred --model_dir=model/190703-214543 --data_dir=demo/mseed --data_list=demo/fname.csv --output_dir=output --batch_size=20 --input_mseed
# Check figures of waveform and predictions:
python run.py --mode=pred --model_dir=model/190703-214543 --data_dir=demo/mseed --data_list=demo/fname.csv --output_dir=output --plot_figure --batch_size=20 --input_mseed
"""
