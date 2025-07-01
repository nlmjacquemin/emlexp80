# syntax=docker/dockerfile:1

FROM mambaorg/micromamba

USER root

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2024-06-11"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils \
	curl \
	git \
	nano \
	less \
	unzip \
	wget \
&& rm -rf /var/lib/apt/lists/*

# Installing software

ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN site=https://mirrors.tuna.tsinghua.edu.cn/anaconda \
&& micromamba config append channels ${site}/pkgs/free/ \
&& micromamba config append channels ${site}/pkgs/main/ \
&& micromamba config append channels ${site}/cloud/conda-forge/ \
&& micromamba config append channels ${site}/cloud/bioconda/

RUN cd /opt \
&& git clone https://github.com/EMBL-PKU/BASALT.git \
&& cd BASALT \
&& micromamba env create -n basalt --file basalt_env.yml

RUN cd /opt && wget https://figshare.com/ndownloader/files/41093033 \
&& mv 41093033 BASALT.zip \
&& mv BASALT.zip ~/.cache \
&& cd ~/.cache \
&& unzip BASALT.zip

RUN cd /opt/BASALT \
&& unzip BASALT_script.zip \
&& mv BASALT_script/* /opt/conda/envs/basalt/bin \
&& rm -rf BASALT_script
 
RUN chmod -R 777 /opt/conda/envs/basalt/bin/*
