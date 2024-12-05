# syntax=docker/dockerfile:1

FROM mambaorg/micromamba

USER root

LABEL org.opencontainers.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL org.opencontainers.image.created="2024-10-20"

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
	&& micromamba create -y -n gtotree -c astrobiomike -c conda-forge -c bioconda -c defaults gtotree

