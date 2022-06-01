FROM nvidia/cuda:10.0-devel

# ---------- UPDATE TOOLS
# ------------------------------

RUN  apt-get update && apt-get install -y less nano vim bsdmainutils git wget
# possible add on wget / unzip / byobu

# ---------- INSTALL MINICONDA3
# ------------------------------
RUN mkdir -p /root/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
            -O /root/miniconda3/miniconda.sh
RUN bash /root/miniconda3/miniconda.sh -b -u -p /root/miniconda3
RUN rm -rf /root/miniconda3/miniconda.sh
COPY BASHRC.conf /root/.bashrc
RUN /root/miniconda3/bin/conda init bash

# ---------- CREATE ENV EQT
# ------------------------------

COPY eqt_tf2_env.PIP.yml eqt_tf2_env.PIP.yml
RUN /root/miniconda3/bin/conda-env create -f eqt_tf2_env.PIP.yml

# ---------- DOWNLOAD MODELs
# ------------------------------

RUN git clone https://github.com/smousavi05/EQTransformer /eqt &&\
    cd /eqt && git checkout 5524b75bfebb3bddf52265356489cce6b9513181 -b working_branch
RUN mv /eqt/ModelsAndSampleData .
RUN rm -rf /eqt

# ---------- FINAL ADJUSTMENT
# ------------------------------

# bashrc
RUN echo "conda activate eqt" >> /root/.bashrc

# Copy modified script
COPY test_eqt_GPU.py  /test_eqt.py
RUN chmod 766 /test_eqt.py


COPY entrypoint_pip_eqt.py /entrypoint_pip_eqt.py
RUN chmod 766 /entrypoint_pip_eqt.py

ENTRYPOINT ["/entrypoint_pip_eqt.py"]


# *** Finished the prediction in: 0 hours and 1 minutes and 42.28 seconds. ONLYCPU
# vi /root/miniconda3/envs/eqt/lib/python3.7/site-packages/EQTransformer/core/predict.py
