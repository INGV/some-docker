FROM nvidia/cuda:10.0-devel

# FROM nvidia/cuda:10.1-devel If using TF>=2.1

RUN  apt-get update && apt-get install -y less nano byobu vim bsdmainutils wget git unzip

# ---------- Install miniconda3 + GPD environment
RUN mkdir -p /root/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
            -O /root/miniconda3/miniconda.sh
RUN bash /root/miniconda3/miniconda.sh -b -u -p /root/miniconda3
RUN rm -rf /root/miniconda3/miniconda.sh
COPY BASHRC.conf /root/.bashrc
RUN /root/miniconda3/bin/conda init bash

# ----------  Install GPD (conda env+pip)
RUN git clone https://github.com/interseismic/generalized-phase-detection /gpd &&\
    cd /gpd && git checkout ea81ef17d204797de6a99d277fd2b9407fc77df7 -b working_branch &&\
    rm -rf /gpd/.git*
# Create env PHASENET
COPY gpd_tf1_env.yml gpd_tf1_env.yml
RUN /root/miniconda3/bin/conda-env create -f gpd_tf1_env.yml
RUN echo "conda activate gpd" >> /root/.bashrc

# Copy modified script
COPY gpd_predict.py /gpd/gpd_predict.py
RUN chmod 766 /gpd/gpd_predict.py
