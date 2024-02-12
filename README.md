# SOME-docker

Collection of docker's images (`Dockerfile`) for machine learning development.
Currently, there are 6 different docker-images to be compiled by the end-user:

For **GPD**:
  - `gpd_conda_tf1_gpu`: This docker represents the original version of GPD as
  described in _Ross et al. (2020)_.
  - `gpd_conda_tf1_gpu.app`: the relative `app` version. Calling this docker will result in
    a direct prediction over miniseed streams.

For **PHASENET**:
  - `phasenet_conda_tf2_gpu` Original implementation as descrived in _Zhu et al. (2019)_.
  - `phasenet_conda_tf2_gpu.app` is the relative `app` version. Calling this docker will result in
    a direct prediction over miniseed streams.

For **EQTransformer** ():
  - `eqt_conda_tf2_gpu`: This docker represents the original version of EQT as
  described in _Mousavi et al. (2020)_. _Still under development_
  - `eqt_conda_tf2_gpu.app`: the relative `app` version. Calling this docker will result in
    a direct prediction over miniseed streams. _Still under development_

PhaseNet picks with the default, pre-trained model. All the additional
flags apart from the `--model` one must be specified. To check everything is
running properly,  there's the utility function `runpn_test` that emulates
the example reported [here](https://github.com/wayneweiqiang/PhaseNet/blob/master/docs/example_batch_prediction.ipynb)

Inside each Docker, there are some shell utils and aliases useful for production.
In addition, for the non-app dockers, the shell prompt is colored differently to distinguish
it from other regular host's shell tabs. There's installed also `byobu` (for
tmux and multishell work) and `jupyter-lab` as well.

Currently, the 2 apps (GPD/PN) are shipped with wrappers for fast In/Out predictions.
Please use the 2 wrappers stored in the respective subfolder.

- `run_gpd_app.sh`
- `run_phasenet_app.sh`

Both wrappers comes with an on-screen helper (`-h`). CHeck it before running.


### HOW TO

To proceed with the Docker builds, you must have Docker already installed on your machine.
Check [here for the details](https://docs.docker.com/engine/install/)

Once installed, proceed with the building:
```bash
$ cd MYDOCKERFOLDER
# Depending on your machine, run:
$ docker build --platform linux/amd64 -t NAME:TAG  # --> emulate linux INTEL
# ... or
$ docker build --platform linux/arm64 -t NAME:TAG  # --> emulate linux MAC-M-processor
```

For running one of the images and accessing the container with a root shell:

```bash
# If you want to run with CPUs only, just remove the `--gpus all` flag

$ docker run --rm --gpus all -it NAME:TAG /bin/bash

# If you want to mount a DATA disk with the necessary waveforms do:

$ docker run --rm --gpus all -v HOSTPATH:MOUNTPATH -it NAME:TAG /bin/bash
```

Please remember that the `HOSTPATH` and `MOUNTPATH` must be **absolute path**

To run the images with GPUs support, you must have the [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
support on your host system. Easiest (and recommended way) is machine-dependent and is listed [here](
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

--------------------------------------------------------------------

#### Useful links

- [nvidia](https://towardsdatascience.com/how-to-properly-use-the-gpu-within-a-docker-container-4c699c78c6d1)
- [use devel CUDA](https://github.com/NVIDIA/nvidia-docker/wiki/CUDA)
- [tf+cuda compatible](https://stackoverflow.com/questions/50622525/which-tensorflow-and-cuda-version-combinations-are-compatible)
- [tf official pairs](https://www.tensorflow.org/install/source#tested_build_configurations)
- [to solve cudann - ( Nicholas-Mitchell commented on Jun 22, 2020 )](https://github.com/tensorflow/tensorflow/issues/20271)
- [for modifying scripts](https://stackoverflow.com/questions/32727594/how-to-pass-arguments-to-shell-script-through-docker-run)

#### REFERENCES
- Mousavi, S.M., Ellsworth, W.L., Zhu, W., Chuang, L.Y., Beroza, G.C., 2020. Earthquake transformer—an attentive deep-learning model for simultaneous earthquake detection and phase picking. Nat Commun 11, 3952. https://doi.org/10.1038/s41467-020-17591-w
- [EQT_github_page](https://github.com/smousavi05/EQTransformer)
- Ross, Z.E., Meier, M.-A., Hauksson, E., Heaton, T.H., 2018. Generalized seismic phase detection with deep learning. Bulletin of the Seismological Society of America 108, 2894–2901.
- [GPD_github_page](https://github.com/interseismic/generalized-phase-detection)
- Zhu, W., Beroza, G.C., 2019. PhaseNet: a deep-neural-network-based seismic arrival-time picking method. Geophys J Int 216, 261–273. https://doi.org/10.1093/gji/ggy423
- [Phasenet_github_page](https://github.com/AI4EPS/PhaseNet)
