#!/bin/bash

MOUNTDIR="/mymount"  # must coincide with RUN_APP shell script


source /root/miniconda3/etc/profile.d/conda.sh
conda activate eqt_conda_tf2
###########################################  BODY
cp /root/eqt_predict_app.py ${MOUNTDIR}; cd ${MOUNTDIR}
#
echo ""
echo ""
if [ -d "${3}_processed_hdfs" ]; then
  # Pre-processed dir already exists
  echo "PRE-PROCESSING DIR already exist:    ${3}_processed_hdfs"
  echo "... removing"
  rm -r ${3}_processed_hdfs
  echo ""
  echo ""
fi
echo ""
echo ""
echo "./eqt_predict_app.py ${@:3}"
echo ""
echo ""
./eqt_predict_app.py ${@:3}
rm eqt_predict_app.py
###########################################
conda deactivate

echo ""
echo "Changing permissions"

# --- The first 2 arguments are UID and GID for permission end
chown ${1}:${2} -R ${MOUNTDIR}
