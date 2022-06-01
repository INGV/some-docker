#!/bin/bash


source ~/miniconda3/etc/profile.d/conda.sh
conda activate gpd_conda_tf1
###########################################

cd
echo "gpd_predict.py $@"

# echo $(id -u)
# echo $(id -g)
ls -l ${HOME}/mymount

# ./gpd_predict.py "$@"
# -I new_anza2016.in -O dedede -g 3 -p 0.95 -V
# echo ""
# echo "DIFFERENCE:"
# diff gpd/anza2016.out dedede
# echo "DONE"

###########################################
conda deactivate

