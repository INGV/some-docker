FROM python:3.7.12-bullseye
RUN  apt-get update && apt-get install -y less nano byobu vim bsdmainutils wget

# Install PHASENET
RUN git clone https://github.com/wayneweiqiang/PhaseNet /phasenet &&\
        cd /phasenet && git checkout c2f41b39b233a1ec14e95965faee5bcde8615cda -b working_branch &&\
        rm -rf /phasenet/.git*

# Move the pinned environment (pinning all requirements from phasenet)
COPY phasenet_requirements.txt /phasenet/requirements.txt
RUN pip install --no-cache-dir --upgrade pip &&\
    pip install --no-cache-dir jupyterlab
RUN cd /phasenet && pip install .

COPY demo_test.py phasenet_demo.py
RUN chmod 766 phasenet_demo.py

# Copy BASHRC to set variables etc
COPY BASHRC.conf /root/.bashrc
