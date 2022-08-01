#!/bin/bash

Help()
{
cat<<EOF
 --->  PHASENET  DockerApp  //  TensorFlow: 2.0 <---
This wrapper will lunch the PhaseNet docker image, implementing the very
one original model (from GitHub page - last accessed 31.05.2022).

Parameters:
        i) csvfile      !!! mandatory input !!! File specifying the paths of data
        d) datadir      !!! mandatory input !!! Actual folder containing the data
        f) dataformat   !!! mandatory input !!! Specify dataformat [mseed, numpy, sac]
        m) mountdisk    [workingdir] Please use ABSOLUTE PATH!
        x) dockerimage  [mbagagli/phasenet_conda_tf2_gpu.app:1.0.0]
        #
        a) minprob_p      Minimum softmax probability for P phase detection [0.3]
        b) minprob_s      Minimum softmax probability for S phase detection [0.3]
        c) highpass       Lower frequency for highpass filtering if filter active [0.0]
        u) force_cpu      Force the usage of Tensorflow-CPU
        g) gpu_device     Specify 1 or more GPU-index (i.e.  0  or 0,1 ). Make
                          sure no spaces are in between indexes if multi-index.
        p) minpeakdist    Minimum peak distance [50.0]
        z) debug          If specified, amplitude and probability will be stored.
                          !!! WARNING !!! If specified, a lot of space will be
                          used. Make sure to have enough space on disk

If GPU not present in the host machine, it will automatically
switch to the CPU-based of TensorFlow. If you want to force
CPU instead, use the -u flag

NB: Please bare in mind that the mountdisk point must be a parent
directory of your input file!

NB: Input and Output files path are referred to the MOUNTING POINT.
Make sure to have writing permission on the HOST disk you're mounting
as a local user (the permission will be handled by the docker inside)
EOF
exit
}

# ---------- PHASENET PREDICT inputs
# parser = argparse.ArgumentParser()
# parser.add_argument("--batch_size", default=20, type=int, help="batch size")
# parser.add_argument("--model_dir", help="Checkpoint directory (default: None)")
# parser.add_argument("--data_dir", default="", help="Input file directory")
# parser.add_argument("--data_list", default="", help="Input csv file")
# parser.add_argument("--hdf5_file", default="", help="Input hdf5 file")
# parser.add_argument("--hdf5_group", default="data", help="data group name in hdf5 file")
# parser.add_argument("--result_dir", default="results", help="Output directory")
# parser.add_argument("--result_fname", default="picks", help="Output file")
# parser.add_argument("--highpass_filter", default=0.0, type=float, help="Highpass filter")
# parser.add_argument("--min_p_prob", default=0.3, type=float, help="Probability threshold for P pick")
# parser.add_argument("--min_s_prob", default=0.3, type=float, help="Probability threshold for S pick")
# parser.add_argument("--mpd", default=50, type=float, help="Minimum peak distance")
# parser.add_argument("--amplitude", action="store_true", help="if return amplitude value")
# parser.add_argument("--format", default="numpy", help="input format")
# parser.add_argument("--s3_url", default="localhost:9000", help="s3 url")
# parser.add_argument("--stations", default="", help="seismic station info")
# parser.add_argument("--plot_figure", action="store_true", help="If plot figure for test")
# parser.add_argument("--save_prob", action="store_true", help="If save result for test")

# debug=false
while getopts "hzui:d:f:m:x:a:b:c:p:g:" flagg
do
    case "${flagg}" in
        #
        i) csvfile=${OPTARG};;
        d) datadir=${OPTARG};;
        f) dataformat=${OPTARG};;
        m) mountdisk=${OPTARG};;
        x) dockerimage=${OPTARG};;
        #
        a) minprob_p=${OPTARG};;
        b) minprob_s=${OPTARG};;
        c) highpass=${OPTARG};;
        u) force_cpu=true;;
        g) gpu_device=${OPTARG};;
        p) minpeakdist=${OPTARG};;
        z) debug=true;;
        #
        h) Help;;
        ?) Help;;
    esac
done

STOREDATE=$(date +'%Y%m%d_%H%M%S')

# --- Set MANDATORY
if [ -z "${csvfile}" ] || [ -z "${datadir}" ] || [ -z "${dataformat}" ]; then
    echo "USAGE:  $(basename $0) -i FILENAME -d DATADIR -f DATAFORMAT (type -h for help)"
    exit
fi

# ------- Set  GENERAL defaults
if [ -z "${mountdisk}" ]; then
    mountdisk=$(pwd)
fi

if [ -z "${outfilename}" ]; then
    outfilename="phasenet_results_${STOREDATE}.txt"
fi

if [ -z "${dockerimage}" ]; then
    dockerimage="mbagagli/phasenet_conda_tf2_gpu.app:1.0.0"
fi

# ------- Set  HYPER-PARAMETERS defaults
if [ -z "${minprob_p}" ]; then
    minprob_p="0.3"
fi

if [ -z "${minprob_s}" ]; then
    minprob_s="0.3"
fi

if [ -z "${highpass}" ]; then
    highpass="0.0"
fi

if [ -z "${minpeakdist}" ]; then
    minpeakdist="50.0"
fi

if [ -z "${filterdata}" ]; then
    filterdata=""
    filterdataHelp="True"
else
    filterdata="-d"
    filterdataHelp="False"
fi

# ======================================================================
# ==========================================================  START GPU

if [ -z "${gpu_device}" ]; then
    usegpulog="ALL"
else
    usegpulog="${gpu_device}"
fi

# # --- Goes for last and override the device selection or the
# #     usage of GPU in general

if [ "${force_cpu}" = true ]; then
    forcecpulog="True"
    forcecpuswitch=true
    usegpulog="NONE"
    usegpuswitch=false
else
    forcecpulog="False"
    forcecpuswitch=false
    usegpuswitch=true
fi

# ==========================================================  END GPU
# ======================================================================

if [ "${debug}" = true ]; then
    debuglog="--amplitude --save_prob"
    debuglogHelp="True"
else
    debuglog=""
    debuglogHelp="False"
fi

# ==============================================  Expand and Run
echo "-----------------------"
echo "    $(basename $0)"
echo "-----------------------"
echo ""
echo "       GENERAL"
echo ""
echo "Input File:         ${filename}"
echo "Input Data Dir:     ${outfilename}"
echo "Input Data Format:  ${outfilename}"
echo ""
echo "MountPoint:  ${mountdisk}"
echo
echo ""
echo "    HYPERPARAMETERS"
echo ""
echo " - Min Prob-P:      ${minprob_p}"
echo " - Min Prob-S:      ${minprob_s}"
echo " - Highpass:        ${highpass}"
echo " - Min Peak Dist.:  ${minpeakdist}"
echo " - Debug Log:       ${debuglogHelp}"
echo " - Force CPU:       ${forcecpulog}"
echo " - GPU device:      ${usegpulog}"
echo ""
echo "Activating DOCKER:  ${dockerimage}"


# #####################
# # Hyperparameters
# min_proba = 0.95       # Minimum softmax probability for phase detection
# freq_min = 3.0
# freq_max = 20.0
# filter_data = True
# decimate_data = False  # If false, assumes data is already 100 Hz samprate
# n_shift = 10           # Number of samples to shift the sliding window at a time


#--user $(id -u):$(id -u) MUST BE THE INITIAL PAR
DOCKERMOUNTPATH="/mymount"  # <---------- NEVER CHANGE THIS !!!

if [ "${forcecpuswitch}" = true ]; then
    # Use CPUs
    echo "... Using only CPU"
    docker run --rm -v ${mountdisk}:${DOCKERMOUNTPATH}  ${dockerimage}\
      $(id -u) $(id -u) --model=model/190703-214543\
      --data_list=${DOCKERMOUNTPATH}/${csvfile}\
      --data_dir=${DOCKERMOUNTPATH}/${datadir}\
      --format=${dataformat}\
      --min_p_prob=${minprob_p}\
      --min_s_prob=${minprob_s}\
      --highpass_filter=${highpass} ${debuglog}

elif [ "${usegpuswitch}" = true ]; then
    # Use GPUs
    echo -n "... Using GPU"
    if [ ! -z "${gpu_device}" ]; then
        # Use specific GPUs
        echo " ... ${gpu_device}"
        docker run --rm --gpus '"'device=${gpu_device}'"' -v ${mountdisk}:${DOCKERMOUNTPATH}  ${dockerimage}\
          $(id -u) $(id -u) --model=model/190703-214543\
          --data_list=${DOCKERMOUNTPATH}/${csvfile}\
          --data_dir=${DOCKERMOUNTPATH}/${datadir}\
          --format=${dataformat}\
          --min_p_prob=${minprob_p}\
          --min_s_prob=${minprob_s}\
          --highpass_filter=${highpass} ${debuglog}
    else
        # Use all GPUs
        echo " ... ALL"
        docker run --rm --gpus all -v ${mountdisk}:${DOCKERMOUNTPATH}  ${dockerimage}\
          $(id -u) $(id -u) --model=model/190703-214543\
          --data_list=${DOCKERMOUNTPATH}/${csvfile}\
          --data_dir=${DOCKERMOUNTPATH}/${datadir}\
          --format=${dataformat}\
          --min_p_prob=${minprob_p}\
          --min_s_prob=${minprob_s}\
          --highpass_filter=${highpass} ${debuglog}
    fi

else
    echo "Something went wrong! I'll do nothing ..."
fi

echo "Finished!"
