FROM nvidia/cuda:10.0-devel

#SHELL [ "/bin/bash", "--login", "-c" ]
RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list
RUN  apt-get update && apt-get install -y wget git

# ---> install the app with CONDA <--- #
# info extracted from https://towardsdatascience.com/conda-pip-and-docker-ftw-d64fe638dc45

# =====================  Install MINICONDA
ENV HOME /root
ENV CONDA_DIR $HOME/miniconda3
RUN mkdir -p $CONDA_DIR

# MINICONDA_VERSION = py39_4.11.0    # the same as per other ML picker
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-py39_4.11.0-Linux-x86_64.sh \
        -O $CONDA_DIR/miniconda.sh

RUN bash $CONDA_DIR/miniconda.sh -b -u -p $CONDA_DIR
RUN rm -rf $CONDA_DIR/miniconda.sh
RUN /root/miniconda3/bin/conda init bash

# make non-activate conda commands available
ENV PATH=$CONDA_DIR/bin:$PATH
# make conda activate command available from /bin/bash --login shells
RUN echo ". $CONDA_DIR/etc/profile.d/conda.sh" >> ${HOME}/.profile

# ... init conda
RUN conda init bash

# ===================== Install GPD (conda env+pip)
RUN git clone https://github.com/interseismic/generalized-phase-detection $HOME/gpd &&\
    cd $HOME/gpd && git checkout ea81ef17d204797de6a99d277fd2b9407fc77df7 -b working_branch &&\
    rm -rf $HOME/gpd/.git*

# copy env
COPY gpd_tf1_env.yml $HOME/gpd_tf1_env.yml

#ENV ENV_PREFIX $PWD/env
RUN conda update --channel defaults conda && \
    conda env create --file $HOME/gpd_tf1_env.yml --force && \
    conda clean --all --yes


# ===================== Set-up GPD
COPY gpd_predict.py  /gpd_predict.py
COPY entrypoint.sh $HOME/entrypoint.sh
ENTRYPOINT ["/root/entrypoint.sh"]
