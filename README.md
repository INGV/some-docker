# SOME-docker

Collection of docker's images (`Dockerfile`) for machine learning development.
At the moment, on the `serra.pi.ingv.it` server, those 2 have been successfullly implemented:

  - `mbagagli/gpd_conda_tf1_gpu:1.0.0`: the `gpd_predict.py` file is already added to the machine's
  bin path. Therefore, it can be summoned everywhere in the system.
  - `mbagagli/phasenet_conda_tf2_gpu:1.0.0`: the `runpn` is an alias for running
  PhaseNet picker with the default, pre-trained model. All the additional
  flags apart from the `--model` one must be specified. To check everything is
  runinng properly,  there's the utility function `runpn_test` that emulates
  the example reported [here](https://github.com/wayneweiqiang/PhaseNet/blob/master/docs/example_batch_prediction.ipynb)

Inside each docker there are some shell utils and alias useful for the production.
In addition, I've also modifyed the prompt to a colored terminal to distinguish
it from other regular host's shell tabs. There's installed also `byobu` (for
tmux and multishell work) and `jupyter-lab` as well.

To run one of the images and access the container with a root shell:

```bash
# If you want to run with CPUs only, just remove the `--gpus all` flag

$ docker run --rm --gpus all -it NAME:TAG /bin/bash

# If you want to mount a DATA disk with the necessary waveforms do:

$ docker run --rm --gpus all -v HOSTPATH:MOUNTPATH -it NAME:TAG /bin/bash
```
NB: please remember that the `HOSTPATH` and `MOUNTPATH` must be **absolute path**


For any bug reports (or additional requests), please write to `matteo.bagagli@ingv.it`.
As soon as all tests are passed, I'll upload them to `dockerhub/mbagagli` so
that a simple `$ docker pull mbagagli/IMAGENAME` call will set you up.

### Useful links

- [nvidia](https://towardsdatascience.com/how-to-properly-use-the-gpu-within-a-docker-container-4c699c78c6d1)
- [use devel CUDA](https://github.com/NVIDIA/nvidia-docker/wiki/CUDA)
- [tf+cuda compatible](https://stackoverflow.com/questions/50622525/which-tensorflow-and-cuda-version-combinations-are-compatible)
- [tf official pairs](https://www.tensorflow.org/install/source#tested_build_configurations)
- [to solve cudann - ( Nicholas-Mitchell commented on Jun 22, 2020 )](https://github.com/tensorflow/tensorflow/issues/20271)

### APPS

Currently there are 2 apps that can be used as simple IN-OUT scripts.
They represent the original images as presented in their GitHub pages.
Please use the 2 wrappers stored in the `bin/` subfolder

- `run_gpd_app.sh`
- `run_phasenet_app.sh`

Both wrappers comes with an on-screen helper (`-h`). Check it out!


###  Installation
In order to run the IMGAES with GPUs support, you must have the [nvidia-docker](https://github.com/NVIDIA/nvidia-docker)
support on your host system. Easyest (and recommended way) is machine-dependent and is listed [here](
https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html#docker)

--------------------------------------------------------------------

# Useful infos

RUN and ENTRYPOINT are two different ways to execute a script.

RUN means it creates an intermediate container, runs the script and
freeze the new state of that container in a new intermediate image.
The script won't be run after that: your final image is supposed to
reflect the result of that script.

ENTRYPOINT means your image (which has not executed the script yet) will create a container, and runs that script.

In both cases, the script needs to be added, and a RUN chmod +x /bootstrap.sh is a good idea.
It should also start with a shebang (like `#!/bin/sh`)

https://stackoverflow.com/questions/32727594/how-to-pass-arguments-to-shell-script-through-docker-run
