#!/usr/bin/env python

import argparse
from EQTransformer.utils.hdf5_maker import preprocessor
from EQTransformer.core.predictor import predictor

MLMODELDIR = "/root/ModelsAndSampleData"

parser = argparse.ArgumentParser(
    prog='eqt_predict.py',
    description='Automatic picking of seismic waves using'
                'the EQTransformer ML algorithm')


# ======================  Mandatory
parser.add_argument("mseed_dir", type=str,
                    help="Directory containing the waveforms MSEED files to be preprocessed")
# --->  After preprocessing "Directory name containing hdf5 and csv files-preprocessed data."

parser.add_argument("stations_json", type=str,
                    help="Path to a JSON file containing station information.")


# ======================  Optional / PREPROC
parser.add_argument("--preproc_dir", type=str, default="preproc",
                    help="Directory containing the results from preprocessing")

parser.add_argument("--overlap", type=float, default=0.3,
                    help="If set the preprocessing is performed in overlapping windows.")

parser.add_argument("--number_of_cpus", type=int, default=5,
                    help="Number of CPUs used for the parallel preprocessing and feeding of data for prediction.")


# ======================  Optional / PREDICT
parser.add_argument("--input_model", type=str, default="EqT_original_model.h5",
                    help="Path to a trained model. Another possibility is ['EqT_model_conservative.h5']")

parser.add_argument("--output_dir", type=str, default="detections",
                    help="Directory containing the predictions output. Output directory that will be generated.")


parser.add_argument("--output_probabilities", type=bool, default=False,
                    help="If True, it will output probabilities and estimated uncertainties for each trace into an HDF file.")

parser.add_argument("--estimate_uncertainty", type=bool, default=False,
                    help="If True uncertainties in the output probabilities will be estimated.")

parser.add_argument("--number_of_sampling", type=int, default=5,
                    help="Number of sampling for the uncertainty estimation.")


parser.add_argument("--detection_threshold", type=float, default=0.3,
                    help="A value which the detection probabilities above it will be considered as an event.")

parser.add_argument("--P_threshold", default=0.1, type=float,
                    help="A value which the P probabilities above it will be considered as P arrival.")

parser.add_argument("--S_threshold", default=0.1, type=float,
                    help="A value which the S probabilities above it will be considered as S arrival.")


parser.add_argument("--loss_weights", type=float, nargs='+', default=[0.03, 0.40, 0.58],
                    help="Loss weights for detection P picking and S picking respectively.")

parser.add_argument("--loss_types", nargs='+', type=str, default=['binary_crossentropy', 'binary_crossentropy', 'binary_crossentropy'],
                    help="Loss types for detection P picking and S picking respectively.")


parser.add_argument("--batch_size", type=int, default=500,
                    help="Batch size. This wont affect the speed much but can affect the performance. A value beteen 200 to 1000 is recommanded.")

parser.add_argument("--normalization_mode", type=str, default="std",
                    help="Mode of normalization for data preprocessing, 'max', maximum amplitude among three components, 'std', standard deviation.")

parser.add_argument("--input_dimention", nargs='+', type=int, default=(6000, 3),
                    help="Matrix dimension fed into the model")


parser.add_argument("--keepPS", type=bool, default=True,
                    help="If True, only detected events that have both P and S picks will be written otherwise those events with either P or S pick.")

parser.add_argument("--spLimit", type=int, default=60,
                    help="S - P time in seconds. It will limit the results to those detections with events that have a specific S-P time limit.")


parser.add_argument("--use_multiprocessing", type=bool, default=True,
                    help="If True, multiple CPUs will be used for the preprocessing of data even when GPU is used for the prediction.")

parser.add_argument("--gpuid", type=str, default=None,
                    help="Id of GPU used for the prediction. If using CPU set to None.")

parser.add_argument("--gpu_limit", type=int, default=None,
                    help="Set the maximum percentage of memory usage for the GPU.")


parser.add_argument("--number_of_plots", type=int, default=10,
                    help="The number of plots for detected events outputed for each station data.")

parser.add_argument("--plot_mode", type=str, default="time",
                    help="The type of plots: 'time': only time series or 'time_frequency', time and spectrograms.")


myargs = parser.parse_args()

# ================================================================= WORK

print("")
print("... PREPROCESSING WAVEFORMS ...")
print("")

preprocessor(preproc_dir=myargs.preproc_dir,
             mseed_dir=myargs.mseed_dir,
             stations_json=myargs.stations_json,
             overlap=myargs.overlap,
             n_processor=myargs.number_of_cpus)


print("")
print("... DOING PREDICTIONS ...")
print("  predictor.py  %r  %r  --output_dir %r" % (myargs.mseed_dir + "_processed_hdfs", MLMODELDIR+"/"+myargs.input_model, myargs.output_dir))
print("     --output_probabilities  %r  --estimate_uncertainty  %r  --number_of_sampling  %r" % (myargs.output_probabilities, myargs.estimate_uncertainty, myargs.number_of_sampling))
print("     --detection_threshold  %r  --P_threshold  %r  --S_threshold  %r" % (myargs.detection_threshold, myargs.P_threshold, myargs.S_threshold))
print("     --loss_weights  %r  --loss_types  %r" % (myargs.loss_weights, myargs.loss_types))
print("     --batch_size  %r  --input_dimention  %r  --normalization_mode  %r" % (myargs.batch_size, myargs.input_dimention, myargs.normalization_mode))
print("     --keepPS  %r  --spLimit  %r" % (myargs.keepPS, myargs.spLimit))
print("     --number_of_cpus  %r  --use_multiprocessing  %r" % (myargs.number_of_cpus, myargs.use_multiprocessing))
print("     --gpuid  %r  --gpu_limit  %r" % (myargs.gpuid, myargs.gpu_limit))
print("     --number_of_plots  %r  --plot_mode  %r" % (myargs.number_of_plots, myargs.plot_mode))
print("")

predictor(
        input_dir=myargs.mseed_dir + "_processed_hdfs",
        input_model=MLMODELDIR+"/"+myargs.input_model,
        output_dir=myargs.output_dir,
        #
        output_probabilities=myargs.output_probabilities,       # default: False
        estimate_uncertainty=myargs.estimate_uncertainty,       # default: False
        number_of_sampling=myargs.number_of_sampling,           # default: 5
        #
        detection_threshold=myargs.detection_threshold,         # default: 0.3
        P_threshold=myargs.P_threshold,                         # default: 0.1
        S_threshold=myargs.S_threshold,                         # default: 0.1
        #
        loss_weights=myargs.loss_weights,                       # default: [0.03, 0.40, 0.58],
        loss_types=myargs.loss_types,                           # default: ['binary_crossentropy', 'binary_crossentropy', 'binary_crossentropy']
        #
        batch_size=myargs.batch_size,                           # default: 500
        input_dimention=myargs.input_dimention,                 # default=(6000, 3)
        normalization_mode=myargs.normalization_mode,           # default='std' ["max"]
        #
        keepPS=myargs.keepPS,                                   # default: True
        # allowonlyS=myargs.allowonlyS,                           # default: True  # Not supported in v0.1.59
        spLimit=myargs.spLimit,                                 # default: 60
        #
        number_of_cpus=myargs.number_of_cpus,                   # default: 5,
        use_multiprocessing=myargs.use_multiprocessing,         # default: True
        gpuid=myargs.gpuid,                                             # "0,1"   int, default=None
        gpu_limit=myargs.gpu_limit,                                         # 0.75    int, default=None
        #
        number_of_plots=myargs.number_of_plots,                 # default: 10
        plot_mode=myargs.plot_mode                              # default: 'time' ["time_frequency"]
        )

"""
Applies a trained model to a windowed waveform to perform both detection and picking at the same time.


Parameters
----------
input_dir: str, default=None
    Directory name containing hdf5 and csv files-preprocessed data.

input_model: str, default=None
    Path to a trained model.

output_dir: str, default=None
    Output directory that will be generated.

output_probabilities: bool, default=False
    If True, it will output probabilities and estimated uncertainties for each trace into an HDF file.

detection_threshold : float, default=0.3
    A value in which the detection probabilities above it will be considered as an event.

P_threshold: float, default=0.1
    A value which the P probabilities above it will be considered as P arrival.

S_threshold: float, default=0.1
    A value which the S probabilities above it will be considered as S arrival.

number_of_plots: float, default=10
    The number of plots for detected events outputed for each station data.

plot_mode: str, default='time'
    The type of plots: 'time': only time series or 'time_frequency', time and spectrograms.

estimate_uncertainty: bool, default=False
    If True uncertainties in the output probabilities will be estimated.

number_of_sampling: int, default=5
    Number of sampling for the uncertainty estimation.

loss_weights: list, default=[0.03, 0.40, 0.58]
    Loss weights for detection, P picking, and S picking respectively.

loss_types: list, default=['binary_crossentropy', 'binary_crossentropy', 'binary_crossentropy']
    Loss types for detection, P picking, and S picking respectively.

input_dimention: tuple, default=(6000, 3)
    Loss types for detection, P picking, and S picking respectively.

normalization_mode: str, default='std'
    Mode of normalization for data preprocessing, 'max', maximum amplitude among three components, 'std', standard deviation.

batch_size: int, default=500
    Batch size. This wont affect the speed much but can affect the performance. A value beteen 200 to 1000 is recommanded.

gpuid: int, default=None
    Id of GPU used for the prediction. If using CPU set to None.

gpu_limit: int, default=None
    Set the maximum percentage of memory usage for the GPU.

number_of_cpus: int, default=5
    Number of CPUs used for the parallel preprocessing and feeding of data for prediction.

use_multiprocessing: bool, default=True
    If True, multiple CPUs will be used for the preprocessing of data even when GPU is used for the prediction.

keepPS: bool, default=True
    If True, only detected events that have both P and S picks will be written otherwise those events with either P or S pick.

spLimit: int, default=60
    S - P time in seconds. It will limit the results to those detections with events that have a specific S-P time limit.

Returns
--------
./output_dir/STATION_OUTPUT/X_prediction_results.csv: A table containing all the detection, and picking results. Duplicated events are already removed.

./output_dir/STATION_OUTPUT/X_report.txt: A summary of the parameters used for prediction and performance.

./output_dir/STATION_OUTPUT/figures: A folder containing plots detected events and picked arrival times.

./time_tracks.pkl: A file containing the time track of the continous data and its type.


Notes
--------
Estimating the uncertainties requires multiple predictions and will increase the computational time.

"""
