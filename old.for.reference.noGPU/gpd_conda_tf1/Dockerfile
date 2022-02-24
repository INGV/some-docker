FROM ubuntu:18.04

RUN apt-get update && apt-get install -y git nano vim bsdmainutils byobu wget


RUN mkdir -p /root/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
            -O /root/miniconda3/miniconda.sh
RUN bash /root/miniconda3/miniconda.sh -b -u -p /root/miniconda3
RUN rm -rf /root/miniconda3/miniconda.sh

#RUN pip install --no-cache-dir --upgrade pip && \
#    pip install --no-cache-dir  obspy==1.2.2 keras==2.3.1 &&\
#    pip install --no-cache-dir  tensorflow==2.1.0

#RUN pip install --no-cache-dir -r  /requirements-gpd.txt
#RUN pip install --no-cache-dir obspy==1.2.2

# Install GPD
RUN git clone https://github.com/interseismic/generalized-phase-detection /gpd &&\
    cd /gpd && git checkout ea81ef17d204797de6a99d277fd2b9407fc77df7 &&\
    rm -rf /gpd/.git*

# Install ENVIRONMENT
COPY gpd_requirements.txt gpd_requirements.txt

# Copy BASHRC to set variables etc
COPY BASHRC.conf /root/.bashrc
RUN ln -s /usr/bin/env /bin/env
#RUN /root/miniconda3/bin/conda init bash

RUN /root/miniconda3/bin/conda create --name gpd --file gpd_requirements.txt
RUN /root/miniconda3/bin/conda init bash
RUN echo "conda activate gpd" >> /root/.bashrc



# ---------------- Version
# ea81ef17d204797de6a99d277fd2b9407fc77df7
# numpy=1.21.5
# matplotlib=3.5.1
# pandas=1.3.5
# obspy=1.2.2
# tensorflow-gpu==1.15
# keras==2.3.0

# Python=3.6.8
#obspy==1.2.2
#Keras==2.3.1
#tensorflow==2.1.0

# ./gpd_predict.py -V -I anza2016.in -O anza2016.out


#mkdir -p ~/miniconda3
#wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
#bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
#rm -rf ~/miniconda3/miniconda.sh
#~/miniconda3/bin/conda init bash
#~/miniconda3/bin/conda init zsh

#usage: /root/miniconda3/miniconda.sh [options]
#
#Installs Miniconda3 4.6.14
#
#-b           run install in batch mode (without manual intervention),
#             it is expected the license terms are agreed upon
#-f           no error if install prefix already exists
#-h           print this help message and exit
#-p PREFIX    install prefix, defaults to /root/miniconda3, must not contain spaces.
#-s           skip running pre/post-link/install scripts
#-u           update an existing installation
#-t           run package tests after installation (may install conda-build)


# https://waylonwalker.com/install-miniconda/
