#!/bin/bash

Help()
{
cat<<EOF
 --->  GPD  DockerApp  //  TensorFlow: 1.15 <---
This wrapper will lunch the Generalized Phase Detector docker
under the hood!

Input data must be sampled at 100 Hz! Make sure to pre-process the
waveforms accordingly. The GPD algorithm will anyway

Parameters:
        i) filename      !!! mandatory input !!! Specifying the paths of MSEED
        o) outfilename  [gpd_results_DATE.txt]
        m) mountdisk    [workingdir] Please use ABSOLUTE PATH!
        g) ngpu         [1]
        x) dockerimage  [mbagagli/gpd_conda_tf1_gpu.app:1.0.0]
        #
        a) minprob      Minimum softmax probability for phase detection [0.95]
        b) fmin         Lower frequency for bandpass filtering if filter active [3]
        c) fmax         Upper frequency for bandpass filtering if filter active [20]
        d) filterdata   Switch to filter the input waveforms. No argument requested.
                        If specified, the GPD **will not** filter. Default does!
        e) decimatedata Switch to decimate the data. To be used if inputs are
                        not sampled @ 100 Hz. No argument requested.
                        If specified, the GPD **will** decimate. Default does not!
        f) nshift       Number of samples to shift the sliding window at a time [10]

If GPU not present in the host machine, it will automatically
switch to the CPU-based TensorFlow 1.15.
If the ngpu paramenter exceed the available GPU, it will still take all the
available ones.

NB: Please bare in mind that the mountdisk point must be a parent
directory of your input file!

NB: Input and Output files path are referred to the MOUNTING POINT.
Make sure to have writing permission on the HOST disk you're mounting
as a local user (the permission will be handled by the docker inside)
EOF
exit
}

while getopts "hi:a:b:c:d:e:f:g:m:o:x:" flagg
do
    case "${flagg}" in
        #
        i) filename=${OPTARG};;
        m) mountdisk=${OPTARG};;
        g) ngpu=${OPTARG};;
        o) outfilename=${OPTARG};;
        x) dockerimage=${OPTARG};;
        #
        a) minprob=${OPTARG};;
        b) fmin=${OPTARG};;
        c) fmax=${OPTARG};;
        d) filterdata=${OPTARG};;
        e) decimatedata=${OPTARG};;
        f) nshift=${OPTARG};;
        #
        h) Help;;
        ?) Help;;
    esac
done

STOREDATE=$(date +'%Y%m%d_%H%M%S')

# --- Set MANDATORY
if [ -z "${filename}" ]; then
    echo "USAGE:  $(basename $0) -i FILENAME  (type -h for help)"
    exit
fi


# ------- Set  GENERAL defaults
if [ -z "${mountdisk}" ]; then
    mountdisk=$(pwd)
fi
# else
#     mountdisk=$(realpath "${mountdisk}")
# fi

if [ -z "${ngpu}" ]; then
    ngpu="1"
fi

if [ -z "${outfilename}" ]; then
    outfilename="gpd_results_${STOREDATE}.txt"
fi

if [ -z "${dockerimage}" ]; then
    dockerimage="mbagagli/gpd_conda_tf1_gpu.app:1.0.0"
fi

# ------- Set  HYPER-PARAMETERS defaults
if [ -z "${minprob}" ]; then
    minprob="0.95"
fi

if [ -z "${fmin}" ]; then
    fmin="3.0"
fi

if [ -z "${fmax}" ]; then
    fmax="20.0"
fi

if [ -z "${filterdata}" ]; then
    filterdata=""
    filterdataHelp="True"
else
    filterdata="-d"
    filterdataHelp="False"
fi

if [ -z "${decimatedata}" ]; then
    decimatedata=""
    decimatedataHelp="False"
else
    decimatedata="-e"
    decimatedataHelp="True"
fi

if [ -z "${nshift}" ]; then
    nshift="10"
fi

# ==============================================  Expand and Run
echo "-----------------------"
echo "    $(basename $0)"
echo "-----------------------"
echo ""
echo "       GENERAL"
echo ""
echo "InputFile:   ${filename}"
echo "OutputFile:  ${outfilename}"
echo ""
echo "MountPoint:  ${mountdisk}"
echo "N-GPU:       ${ngpu}"
echo ""
echo "    HYPERPARAMETERS"
echo ""
echo " - Prob. Threshold:  ${minprob}"
echo " - Low frequency:    ${fmin}"
echo " - Upper frequency:  ${fmax}"
echo " - Filter data:      ${filterdataHelp}"
echo " - Decimate data:    ${decimatedataHelp}"
echo " - Slide shifting:   ${nshift}"
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
docker run --rm --gpus all -v ${mountdisk}:${DOCKERMOUNTPATH}  ${dockerimage}\
  $(id -u) $(id -u) -I ${DOCKERMOUNTPATH}/${filename} \
  -O ${DOCKERMOUNTPATH}/${outfilename} -V -g ${ngpu} -a ${minprob}\
  -b ${fmin} -c ${fmax} ${filterdata} ${decimatedata} -f ${nshift}

# =============  To make the output valid for pandas
echo ""
echo "Converting for PANDAS format"
sed 's/ /,/g' ${mountdisk}/${outfilename} > .tmpbody
echo "NETWORK,STATION,PHASE,UTCDATETIME" > .tmphead
cat .tmphead .tmpbody > .tmpmerge
mv .tmpmerge ${mountdisk}/${outfilename}
rm .tmphead .tmpbody
# =============

echo "Finished!"
