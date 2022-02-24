FROM python:3.6.8-stretch
RUN  apt-get update && apt-get install -y less nano byobu vim bsdmainutils wget
#RUN apt-get update && apt-get install -y git nano vim bsdmainutils byobu wget python3-pip

#RUN pip install --no-cache-dir --upgrade pip && \
#    pip install --no-cache-dir  obspy==1.2.2 keras==2.3.1 &&\
#    pip install --no-cache-dir  tensorflow==2.1.0
COPY gpd_requirements_pip_TF2.txt /gpd_requirements_pip_TF2.txt

# Install python 3.6 + pinned dependencies
RUN pip install --no-cache-dir --upgrade pip &&\
    pip install --no-cache-dir jupyterlab &&\
    pip install --no-cache-dir -r /gpd_requirements_pip_TF2.txt

# Obspy must be installed afterwards, as it needs numpy already installed
RUN pip install --no-cache-dir obspy==1.2.1

# Install GPD
RUN git clone https://github.com/interseismic/generalized-phase-detection /gpd &&\
    cd /gpd && git checkout ea81ef17d204797de6a99d277fd2b9407fc77df7 -b working_branch &&\
    rm -rf /gpd/.git*

# Copy BASHRC to set variables etc
COPY BASHRC.conf /root/.bashrc
COPY gpd_predict.py /gpd/gpd_predict.py
RUN chmod 766 /gpd/gpd_predict.py



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

