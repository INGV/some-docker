FROM nvidia/cuda:10.1-devel

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

# =====================  Install PHASENET (conda env+pip)
RUN git clone https://github.com/wayneweiqiang/PhaseNet $HOME/phasenet &&\
        cd $HOME/phasenet && git checkout c2f41b39b233a1ec14e95965faee5bcde8615cda -b working_branch &&\
        rm -rf $HOME/phasenet/.git*

# Copy env PHASENET
COPY environment_phasenet_working.PINNED.USEME.yml  $HOME/phasenet_env.yml

# Create env
RUN conda update --channel defaults conda && \
    conda env create --file $HOME/phasenet_env.yml --force && \
    conda clean --all --yes
#RUN echo "conda activate phasenet" >> $HOME/.bashrc

# =====================  Finalize (conda env+pip)
COPY entrypoint.sh  $HOME/entrypoint.sh
COPY create_pick_dataframe.py  $HOME/create_pick_dataframe.py
ENTRYPOINT ["/root/entrypoint.sh"]

### https://github.com/wayneweiqiang/PhaseNet/pull/21 --> implement this!
