#!/bin/bash

MOUNTDIR="/mymount"  # must coincide with RUN_APP shell script
HOMEDIR="/root"
PHASENETDIR="/root/phasenet"

source /root/miniconda3/etc/profile.d/conda.sh
conda activate phasenet_conda_tf2

###########################################  BODY
cd ${PHASENETDIR}
echo ""
echo "DOCKER: Running ..."
echo "DOCKER: python phasenet/predict.py ${@:3}"
echo ""
python phasenet/predict.py ${@:3}
# -- From https://github.com/wayneweiqiang/PhaseNet/blob/master/docs/example_batch_prediction.ipynb
# python phasenet/predict.py --model=model/190703-214543
#       --data_list=test_data/npz.csv
#       --data_dir=test_data/npz  --format=numpy --plot_figure
echo ""
finalPicks="phasenet_results_$(date +'%Y%m%d_%H%M%S').csv"
resultsDir="results_$(date +'%Y%m%d_%H%M%S')"

mv results ${MOUNTDIR}/${resultsDir}
cp ${HOMEDIR}/create_pick_dataframe.py  ${MOUNTDIR}/${resultsDir}

cd ${MOUNTDIR}/${resultsDir}
python create_pick_dataframe.py
rm create_pick_dataframe.py

mv phasenet_picks_dataframe.csv ${MOUNTDIR}/${finalPicks}
###########################################
conda deactivate
echo ""
echo "DOCKER: Changing permissions"

# --- The first 2 arguments are UID and GID for permission end
chown ${1}:${2} -R ${MOUNTDIR}
