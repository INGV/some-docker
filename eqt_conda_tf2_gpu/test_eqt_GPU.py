#!/usr/bin/env python

import os
json_basepath = os.path.join(os.getcwd(), "json/station_list.json")

from EQTransformer.utils.downloader import makeStationList
makeStationList(json_path=json_basepath, client_list=["SCEDC"],
                min_lat=35.50, max_lat=35.60, min_lon=-117.80,
                max_lon=-117.40, start_time="2019-09-01 00:00:00.00",
                end_time="2019-09-03 00:00:00.00",
                channel_list=["HH[ZNE]", "HH[Z21]", "BH[ZNE]"],
                filter_network=["SY"], filter_station=[])


from EQTransformer.utils.downloader import downloadMseeds
downloadMseeds(client_list=["SCEDC", "IRIS"], stations_json=json_basepath,
               output_dir="downloads_mseeds", min_lat=35.50, max_lat=35.60,
               min_lon=-117.80, max_lon=-117.40,
               start_time="2019-09-01 00:00:00.00",
               end_time="2019-09-03 00:00:00.00",
               chunk_size=1, channel_list=[], n_processor=2)


from EQTransformer.utils.hdf5_maker import preprocessor
preprocessor(preproc_dir="preproc", mseed_dir='downloads_mseeds',
             stations_json=json_basepath, overlap=0.3, n_processor=2)

# from EQTransformer.core.predictor import predictor
# predictor(input_dir='downloads_mseeds_processed_hdfs',
#           input_model='ModelsAndSampleData/EqT_model.h5',
#           output_dir='detections', gpuid=2, gpu_limit=90.0,
#           detection_threshold=0.3, P_threshold=0.1, S_threshold=0.1,
#           number_of_plots=100, plot_mode='time')

# --- New
from EQTransformer.core.mseed_predictor import mseed_predictor
mseed_predictor(input_dir='downloads_mseeds',
         input_model='ModelsAndSampleData/EqT_model.h5',
         stations_json=json_basepath,
         output_dir='detections2',
         loss_weights=[0.02, 0.40, 0.58],
         detection_threshold=0.3,
         P_threshold=0.1,
         S_threshold=0.1,
         number_of_plots=0,  # here's the change in frequency
         plot_mode='time_frequency',
         normalization_mode='std',
         batch_size=500,
         overlap=0.3,
         gpuid=None,
         gpu_limit=None)
