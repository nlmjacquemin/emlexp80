# syntax=docker/dockerfile:1

FROM ubuntu:latest

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2023-12-06"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils \
	curl \
	nano \
	less \
	wget \
 && rm -rf /var/lib/apt/lists/*

# Installing software

RUN cd /opt && wget http://opengene.org/fastp/fastp && chmod a+x ./fastp

ENV PATH="${PATH}:/opt"
