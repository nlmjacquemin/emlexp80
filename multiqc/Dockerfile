# syntax=docker/dockerfile:1

FROM ubuntu:latest

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2023-12-11"

ENV DEBIAN_FRONTEND=noninteractive

ENV PATH="${PATH}:/opt"

RUN apt-get update && apt-get install -y \
	apt-utils \
	curl \
	fastqc \
	nano \
	less \
	python3-pip \ 
        python3.10 \ 
	wget \
 && rm -rf /var/lib/apt/lists/*

# Symlink

RUN ln -s /usr/bin/python3 /usr/bin/python

# Installing software

RUN cd /opt && pip install multiqc 

