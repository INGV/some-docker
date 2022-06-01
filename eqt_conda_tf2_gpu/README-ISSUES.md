

# ==================  PIP
# --- Predictor
# from tensorflow.keras.utils import multi_gpu_model

# --- Predictor
# parallel_model = multi_gpu_model(model, gpus=8)

# /root/miniconda3/envs/eqt_tf2/lib/python3.7/site-packages/EQTransformer


#if args['gpuid']:
#    os.environ['CUDA_VISIBLE_DEVICES'] = '{}'.format(args['gpuid'])
#    tf.Session(config=tf.ConfigProto(log_device_placement=True))
#    config = tf.ConfigProto()
#    config.gpu_options.allow_growth = True
#    config.gpu_options.per_process_gpu_memory_fraction = float(args['gpu_limit'])
#    K.tensorflow_backend.set_session(tf.compat.v1.Session(config=config))


#    from tensorflow.keras import backend as K
#    from tensorflow.keras.models import load_model
#    from tensorflow.keras.optimizers import Adam

#    if args['gpuid']:
#        os.environ['CUDA_VISIBLE_DEVICES'] = '{}'.format(args['gpuid'])
#        tf.compat.v1.Session(config=tf.compat.v1.ConfigProto(log_device_placement=True))
#        config = tf.compat.v1.ConfigProto()
#        config.gpu_options.allow_growth = True
#        config.gpu_options.per_process_gpu_memory_fraction = float(args['gpu_limit'])
#        K.set_session(tf.compat.v1.Session(config=config))
