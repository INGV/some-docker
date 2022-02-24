FROM nvidia/cuda:11.2.0-devel-ubuntu18.04

# FROM nvidia/cuda:10.1-devel If using TF>=2.1

RUN  apt-get update && apt-get install -y less nano byobu vim bsdmainutils wget git unzip

# ---------- Install miniconda3 + PHASENET environment
RUN mkdir -p /root/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
            -O /root/miniconda3/miniconda.sh
RUN bash /root/miniconda3/miniconda.sh -b -u -p /root/miniconda3
RUN rm -rf /root/miniconda3/miniconda.sh
COPY BASHRC.conf /root/.bashrc
RUN /root/miniconda3/bin/conda init bash

# ----------  Install GPD (conda env+pip)
RUN git clone https://github.com/smousavi05/EQTransformer /eqt &&\
    cd /eqt && git checkout 5524b75bfebb3bddf52265356489cce6b9513181 -b working_branch &&\
    rm -rf /eqt/.git*

# Create env PHASENET
COPY eqt_tf2_env.yml eqt_tf2_env.yml
RUN /root/miniconda3/bin/conda-env create -f eqt_tf2_env.yml
RUN echo "conda activate eqt" >> /root/.bashrc

# Copy modified script
COPY test_eqt.py  /test_eqt.py
RUN chmod 766 /test_eqt.py
