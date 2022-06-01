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

# ===================== Install GPD (conda env+pip)
RUN git clone https://github.com/interseismic/generalized-phase-detection $HOME/gpd &&\
    cd $HOME/gpd && git checkout ea81ef17d204797de6a99d277fd2b9407fc77df7 -b working_branch &&\
    rm -rf $HOME/gpd/.git*

COPY gpd_tf1_env.yml $HOME/gpd_tf1_env.yml

#ENV ENV_PREFIX $PWD/env
RUN conda update --channel defaults conda && \
    conda env create --file $HOME/gpd_tf1_env.yml --force && \
    conda clean --all --yes

# Copy modified script
COPY gpd_predict.py $HOME/gpd/gpd_predict.py
RUN chmod 766 $HOME/gpd/gpd_predict.py
RUN echo "conda activate gpd_conda_tf1" >> $HOME/.bashrc

