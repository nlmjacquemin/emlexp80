# syntax=docker/dockerfile:1

FROM ubuntu:latest

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2023-11-30"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils \
	nano \
	less \
	libfreetype6-dev \
	libpng-dev \
	pkg-config \
	python3-matplotlib \
	python3-pip \
        python3.10 \
	wget \
 && rm -rf /var/lib/apt/lists/*

# Symlink

RUN ln -s /usr/bin/python3 /usr/bin/python

# Installing software

# MEGAHIT - binary

RUN cd /opt && wget https://github.com/ablab/quast/releases/download/quast_5.2.0/quast-5.2.0.tar.gz && \
tar zvxf quast-5.2.0.tar.gz && rm quast-5.2.0.tar.gz

#RUN cd /opt && ./setup.py install_full

ENV PATH="${PATH}:/opt/quast-5.2.0"
