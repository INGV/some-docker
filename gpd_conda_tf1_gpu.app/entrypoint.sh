#!/bin/bash

MOUNTDIR="/mymount"  # must coincide with RUN_APP shell script


source /root/miniconda3/etc/profile.d/conda.sh
conda activate gpd_conda_tf1
###########################################  BODY
cp gpd_predict.py ${MOUNTDIR}; cd ${MOUNTDIR}
# ./gpd_predict.py -V -I anza2016.in -O boia
echo ""
echo ""
echo "Running ..."
echo "./gpd_predict.py ${@:3}"
echo ""
echo ""
./gpd_predict.py ${@:3}
rm gpd_predict.py
###########################################
conda deactivate

echo ""
echo "Changing permissions"

# --- The first 2 arguments are UID and GID for permission end
chown ${1}:${2} -R ${MOUNTDIR}
