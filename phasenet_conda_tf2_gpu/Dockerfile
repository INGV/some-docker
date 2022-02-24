FROM nvidia/cuda:10.1-devel

RUN  apt-get update && apt-get install -y less nano byobu vim bsdmainutils wget git unzip

# ---------- Install miniconda3 + PHASENET environment
RUN mkdir -p /root/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
            -O /root/miniconda3/miniconda.sh
RUN bash /root/miniconda3/miniconda.sh -b -u -p /root/miniconda3
RUN rm -rf /root/miniconda3/miniconda.sh
COPY BASHRC.conf /root/.bashrc
RUN /root/miniconda3/bin/conda init bash

# ----------  Install PHASENET (conda env+pip)
RUN git clone https://github.com/wayneweiqiang/PhaseNet /phasenet &&\
        cd /phasenet && git checkout c2f41b39b233a1ec14e95965faee5bcde8615cda -b working_branch &&\
        rm -rf /phasenet/.git*
# Create env PHASENET
COPY phasenet_env.yml  phasenet_env.yml
RUN /root/miniconda3/bin/conda-env create -f phasenet_env.yml
RUN echo "conda activate phasenet" >> /root/.bashrc

RUN cd /phasenet &&\
    wget https://github.com/wayneweiqiang/PhaseNet/releases/download/test_data/test_data.zip &&\
    unzip test_data.zip

# Final adjustments ...
RUN echo "alias runpn='python /phasenet/phasenet/predict.py --model=/phasenet/model/190703-214543 '" >> /root/.bashrc
RUN echo "alias runpn_test='python /phasenet/phasenet/predict.py --model=/phasenet/model/190703-214543 --data_list=/phasenet/test_data/npz.csv --data_dir=/phasenet/test_data/npz --format=numpy --plot_figure'" >> /root/.bashrc
