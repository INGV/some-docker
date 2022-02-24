# How to

If you want to use the GPUs use the flag `--gpus all`

docker run --rm --gpus all -it mbagagli/phasenet_conda_tf2_gpu:1.0.0 /bin/bash

Otherwise it will run with CPU only
