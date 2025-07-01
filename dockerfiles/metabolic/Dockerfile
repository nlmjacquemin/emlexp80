# syntax=docker/dockerfile:1

FROM mambaorg/micromamba

USER root

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2023-12-06"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils \
	curl \
	git \
	nano \
	less \
	wget \
&& rm -rf /var/lib/apt/lists/*

# Installing software

ARG MAMBA_DOCKERFILE_ACTIVATE=1

RUN cd /opt \
&& wget https://raw.githubusercontent.com/AnantharamanLab/METABOLIC/master/METABOLIC_v4.0_env.yml

RUN cd /opt \
&& micromamba env create -y -f /opt/METABOLIC_v4.0_env.yml

#RUN cd /opt \
#&& micromamba env config vars set GTDBTK_DATA_PATH="db/gtdb"

RUN cd /opt \
&& git clone https://github.com/AnantharamanLab/METABOLIC.git

#RUN cd /opt/METABOLIC \
#&& micromamba run -n METABOLIC_v4.0 bash run_to_setup.sh

RUN chmod -R 777 /opt/METABOLIC

ENV PATH="${PATH}:/opt/METABOLIC"

#RUN chmod 777 /opt/conda/envs/checkm2/lib/python3.8/site-packages/checkm2/version/diamond_path.json

