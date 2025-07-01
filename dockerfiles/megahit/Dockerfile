# syntax=docker/dockerfile:1

FROM ubuntu:latest

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2023-11-30"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils \
	nano \
	python3-pip \
        python3.10 \
	wget \
 && rm -rf /var/lib/apt/lists/*

# Symlink

RUN ln -s /usr/bin/python3 /usr/bin/python

# Installing software

# MEGAHIT - binary

RUN wget https://github.com/voutcn/megahit/releases/download/v1.2.9/MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz && \
tar zvxf MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz -C /opt && rm MEGAHIT-1.2.9-Linux-x86_64-static.tar.gz

ENV PATH="${PATH}:/opt/MEGAHIT-1.2.9-Linux-x86_64-static/bin"
