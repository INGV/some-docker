#!/bin/bash

Help()
{
cat<<EOF
 --->  EQTRANSFORMER  DockerApp  //  TensorFlow: 2.0 <---
This wrapper will lunch the EQTransformer docker image, implementing the very
one original model (from GitHub page - last accessed 21.06.2022).

Parameters:

        i) Input mseed-dir:       !!! mandatory input !!! File specifying the paths of data
        s) Input stations-json:   !!! mandatory input !!! Actual folder containing the data
        o) Output predictions:      eqtransformer_detections_DATE
        p) Output preprocessing:    eqtransformer_preprocessing_DATE
        m) mountdisk:               [workingdir] Please use ABSOLUTE PATH!
        d) dockerimage:             [mbagagli/eqt_conda_tf2_gpu.app:1.0.0]
        x) scriptline:             ""


If GPU not present in the host machine, it will automatically
switch to the CPU-based of TensorFlow.

NB: Please bare in mind that the mountdisk point must be a parent
directory of your input file!

NB: Input and Output files path are referred to the MOUNTING POINT.
Make sure to have writing permission on the HOST disk you're mounting
as a local user (the permission will be handled by the docker inside)!

NB: script's parameter line must be quoted!!! Check inside the
shell script all possibilities.
EOF
exit
}




# Parameters
# ----------
# --input_dir: str, default=None
#     Directory name containing hdf5 and csv files-preprocessed data.

# --input_model: str, default=None
#     Path to a trained model.

# --output_dir: str, default=None
#     Output directory that will be generated.

# --output_probabilities: bool, default=False
#     If True, it will output probabilities and estimated uncertainties for each trace into an HDF file.

# --detection_threshold : float, default=0.3
#     A value in which the detection probabilities above it will be considered as an event.

# --P_threshold: float, default=0.1
#     A value which the P probabilities above it will be considered as P arrival.

# --S_threshold: float, default=0.1
#     A value which the S probabilities above it will be considered as S arrival.

# --number_of_plots: float, default=10
#     The number of plots for detected events outputed for each station data.

# --plot_mode: str, default='time'
#     The type of plots: 'time': only time series or 'time_frequency', time and spectrograms.

# --estimate_uncertainty: bool, default=False
#     If True uncertainties in the output probabilities will be estimated.

# --number_of_sampling: int, default=5
#     Number of sampling for the uncertainty estimation.

# --loss_weights: list, default=[0.03, 0.40, 0.58]
#     Loss weights for detection, P picking, and S picking respectively.

# --loss_types: list, default=['binary_crossentropy', 'binary_crossentropy', 'binary_crossentropy']
#     Loss types for detection, P picking, and S picking respectively.

# --input_dimention: tuple, default=(6000, 3)
#     Matrix dimensions in input to the model

# --normalization_mode: str, default='std'
#     Mode of normalization for data preprocessing, 'max', maximum amplitude among three components, 'std', standard deviation.

# --batch_size: int, default=500
#     Batch size. This wont affect the speed much but can affect the performance. A value beteen 200 to 1000 is recommanded.

# --gpuid: int, default=None
#     Id of GPU used for the prediction. If using CPU set to None.

# --gpu_limit: int, default=None
#     Set the maximum percentage of memory usage for the GPU.

# --number_of_cpus: int, default=5
#     Number of CPUs used for the parallel preprocessing and feeding of data for prediction.

# --use_multiprocessing: bool, default=True
#     If True, multiple CPUs will be used for the preprocessing of data even when GPU is used for the prediction.

# --keepPS: bool, default=True
#     If True, only detected events that have both P and S picks will be written otherwise those events with either P or S pick.

# --spLimit: int, default=60
#     S - P time in seconds. It will limit the results to those detections with events that have a specific S-P time limit.





while getopts "hi:s:o:p:m:d:x:" flagg
do
    case "${flagg}" in
        h) Help;;
        #
        i) mseeddir=${OPTARG};;
        s) stations=${OPTARG};;
        o) output_dir=${OPTARG};;
        p) preproc_dir=${OPTARG};;
        #
        m) mountdisk=${OPTARG};;
        d) dockerimage=${OPTARG};;
        x) scriptline=${OPTARG};;
    esac
done


STOREDATE=$(date +'%Y%m%d_%H%M%S')

# --- Set MANDATORY
if [ -z "${mseeddir}" ] || [ -z "${stations}" ]; then
    echo "USAGE:  $(basename $0) -i MSEEDDIR -s STATIONS_JSON (type -h for help)"
    exit
fi

# ------- Set  DEFAULTS
if [ -z "${mountdisk}" ]; then
    mountdisk=$(pwd)
fi

if [ -z "${dockerimage}" ]; then
    dockerimage="mbagagli/eqt_conda_tf2_gpu.app:1.0.0"
fi

if [ -z "${output_dir}" ]; then
    output_dir="eqtransformer_detections_${STOREDATE}"
fi

if [ -z "${preproc_dir}" ]; then
    preproc_dir="eqtransformer_preprocessing_${STOREDATE}"
fi


# ==============================================  Expand and Run
echo "-----------------------"
echo "    $(basename $0)"
echo "-----------------------"
echo ""
echo "       GENERAL"
echo ""
echo "Input mseed-dir:         ${mseeddir}"
echo "Input stations-json:     ${stations}"
echo "Output predictions:      ${output_dir}"
echo "Output preprocessing:    ${preproc_dir}"
echo ""
echo "MountPoint:              ${mountdisk}"
echo ""
echo "Container Name:  ${dockerimage}"


# ==========================================================  RUN!

#--user $(id -u):$(id -u) MUST BE THE INITIAL PAR
DOCKERMOUNTPATH="/mymount"  # <---------- NEVER CHANGE THIS !!!

echo ""
echo "     !!! RUNNING !!!"
echo ""
echo "docker run --rm --gpus all -v ${mountdisk}:${DOCKERMOUNTPATH}  ${dockerimage}"
echo "   $(id -u) $(id -u) ${mseeddir} ${stations}"
echo "   --preproc_dir ${preproc_dir}  --output_dir ${output_dir}"
echo "   ${scriptline}"
echo ""
echo "-----------------------------------------------  DOCKER STARTS"


docker run --rm --gpus all -v ${mountdisk}:${DOCKERMOUNTPATH}  ${dockerimage}\
  $(id -u) $(id -u) ${mseeddir} ${stations}\
  --preproc_dir ${preproc_dir}\
  --output_dir ${output_dir}\
  ${scriptline}


  # --preproc_dir ${preproc_dir}\
  # --preproc_overlap ${preproc_overlap}\
  # --preproc_ncpu ${preproc_ncpu}\
  # --input_model ${input_model}\
  # --output_dir ${output_dir}\
  # --loss_weights ${loss_weights}\
  # --detection_threshold ${detection_threshold}\
  # --P_threshold ${P_threshold}\
  # --S_threshold ${S_threshold}\
  # --loss_types ${loss_types}\
  # --normalization_mode ${normalization_mode}\
  # --batch_size ${batch_size}\
  # --predict_overlap ${predict_overlap}\
  # ${gpuid}  ${gpu_limit}

echo "Finished!"




