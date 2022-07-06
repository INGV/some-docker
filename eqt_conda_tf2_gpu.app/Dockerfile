FROM nvidia/cuda:10.0-devel

ENV HOME /root
ENV CONDA_DIR $HOME/miniconda3

# FROM nvidia/cuda:10.1-devel If using TF>=2.1
RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
RUN apt-get update && apt-get install -y less nano byobu vim bsdmainutils wget git unzip
COPY BASHRC.conf $HOME/.bashrc

# =====================  Install MINICONDA
RUN mkdir -p $CONDA_DIR

# MINICONDA_VERSION = py39_4.11.0    # the same as per other ML picker
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh \
        -O $CONDA_DIR/miniconda.sh

RUN bash $CONDA_DIR/miniconda.sh -b -u -p $CONDA_DIR
RUN rm -rf $CONDA_DIR/miniconda.sh

# make non-activate conda commands available
ENV PATH=$CONDA_DIR/bin:$PATH
# make conda activate command available from /bin/bash --login shells
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ${HOME}/.profile
# init conda
RUN conda init bash

# ===================== Install EQT (conda env+pip)

# Next one is the working one!
COPY eqt_tf2_env.PIP.yml $HOME/eqt_tf2_env.yml

# This one was a try for TF 2.5 --> failed, runs only on CPU
#COPY eqt_tf2_env.CONDA.yml $HOME/eqt_tf2_env.yml

RUN conda update --channel defaults conda && \
    conda env create --file $HOME/eqt_tf2_env.yml --force && \
    conda clean --all --yes

# ===================== Downloads MODEL (conda env+pip)
# 5524b75bfebb3bddf52265356489cce6b9513181 OldCommit
# 01bf112a00c1a3bbb43adb2c7dba3e21b5fbcdb9 NewCommit  20-06-2020
RUN git clone https://github.com/smousavi05/EQTransformer $HOME/eqt &&\
    cd $HOME/eqt && git checkout 01bf112a00c1a3bbb43adb2c7dba3e21b5fbcdb9 -b working_branch
RUN mv $HOME/eqt/ModelsAndSampleData $HOME/
RUN rm -rf $HOME/eqt


# ===================== FINAL ADJUSTMENT
# Copy modified script
COPY eqt_predict_app.py $HOME/eqt_predict_app.py
RUN chmod 766 $HOME/eqt_predict_app.py
RUN echo "conda activate eqt_conda_tf2" >> $HOME/.bashrc

# Copy TF1 Session mod in predictor.py already installed by PIP
COPY predictor_tf2_tf1_session.py $HOME/miniconda3/envs/eqt_conda_tf2/lib/python3.7/site-packages/EQTransformer/core/predictor.py

COPY entrypoint.sh $HOME/entrypoint.sh
RUN chmod 766 $HOME/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]


# /root/miniconda3/envs/eqt_conda_tf2/lib/python3.7/site-packages/EQTransformer/core/predictor.py


#     --gpuid  0,1  --gpu_limit 0.75
#     --number_of_plots  10  --plot_mode  'time'
#
#Traceback (most recent call last):
#  File "./eqt_predict_app.py", line 168, in <module>
#    plot_mode=myargs.plot_mode                              # default: 'time' ["time_frequency"]
#  File "/root/miniconda3/envs/eqt_conda_tf2/lib/python3.7/site-packages/EQTransformer/core/predictor.py", line 201, in predictor
#    tf.Session(config=tf.ConfigProto(log_device_placement=True))
#AttributeError: module 'tensorflow' has no attribute 'Session'

