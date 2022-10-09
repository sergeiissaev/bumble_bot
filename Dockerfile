# syntax=docker/dockerfile:1
ARG PROJECT=bumble_bot
ARG AUTHOR=Vooban/AI-Team
ARG USER_NAME=appuser
ARG ENV_YML=environment.yml
ARG APP_DIR=/opt/$PROJECT
ARG VIRTUAL_ENV=/opt/venv

# Stage 1: Base
# Use Ubuntu image if no cuda required
# Use cuda base image if cuda required (pytorch comes with cuda runtime and cudnn binaries)
FROM nvidia/cuda:11.3.1-base-ubuntu20.04 AS base
# FROM ubuntu:20.04 AS base
ARG VIRTUAL_ENV
ARG PROJECT
ARG AUTHOR

LABEL project=$PROJECT  \
      author=$AUTHOR  \
      stage=base

ENV TZ=America/Toronto  \
    PYTHONDONTWRITEBYTECODE=1  \
    VENV_PATH=$VIRTUAL_ENV

ARG DEBIAN_FRONTEND=noninteractive
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime  \
 && echo $TZ > /etc/timezone  \
 && apt-get update  \
 && apt-get upgrade -y  \
 && apt-get clean  \
 && rm -rf /var/lib/apt/lists/*


# Stage 2: Python builder with conda and conda-pack
#FROM continuumio/miniconda3 as builder
FROM condaforge/mambaforge as builder
ARG VIRTUAL_ENV
ARG PROJECT
ARG AUTHOR
ARG ENV_YML
ARG TMP_FILE=/tmp/env.tar

LABEL project=$PROJECT  \
      author=$AUTHOR  \
      stage=builder

WORKDIR $VIRTUAL_ENV
COPY envs/$ENV_YML ./envs/requirements*.txt ./

ARG PIP_NO_CACHE_DIR=1
RUN conda install conda-pack  \
 && conda env create -f $ENV_YML -n conda_env  \
 && conda-pack -n conda_env -o $TMP_FILE --compress-level 0  \
 && conda env remove -n conda_env  \
 && tar xf $TMP_FILE  \
 && rm $TMP_FILE


# Stage 3: Production
FROM base AS prod
ARG USER_NAME
ARG APP_DIR

LABEL stage=prod

WORKDIR $APP_DIR
COPY --link --from=builder $VENV_PATH $VENV_PATH
COPY ./setup.py ./
COPY ./src ./src
COPY ./tests ./tests
COPY ./models ./models

SHELL ["/bin/bash", "-c"]
RUN source $VENV_PATH/bin/activate  \
 && $VENV_PATH/bin/conda-unpack  \
 && pip install --no-cache-dir .  \
 && useradd $USER_NAME  \
 && chown -R $USER_NAME $APP_DIR

USER $USER_NAME
ENTRYPOINT ["/bin/bash", "-c", "source $VENV_PATH/bin/activate && $0 $@"]
CMD ["python -m bumble_bot"]
