# syntax=docker/dockerfile:1

FROM ubuntu:latest

LABEL eml.labs.ch.epfl.image.authors="Nicolas Jacquemin <nicolas.jacquemin.1@gmail.com>, EPFL-ENAC-EML <rizlan.bernier-latmani@epfl.ch>"
LABEL eml.labs.ch.epfl.image.created="2023-11-30"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
	apt-utils \
	build-essential \
	bzip2 \
	cmake \
	curl \
	gcc \
	git \
	nano \
	libbz2-dev \
	liblzma-dev \
	libncurses-dev \
	less \
	wget \
	unzip \
	zlib1g-dev \
&& rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/opt/strobealign/build"

#RUN cd /opt && \
#wget https://zlib.net/current/zlib.tar.gz && \
#tar -xvzf zlib.tar.gz && rm zlib.tar.gz && \
#cd zlib-1.3 && \
#./configure --prefix=/opt/zlib && \
#make install

RUN cd /opt && \
git clone https://github.com/ksahlin/strobealign && \
cd strobealign && \
cmake -B build -DCMAKE_C_FLAGS="-msse4.2" -DCMAKE_CXX_FLAGS="-msse4.2" && \
make -j -C build


# Samtools

RUN cd /opt && wget https://github.com/samtools/samtools/releases/download/1.18/samtools-1.18.tar.bz2 && \
tar -vxjf samtools-1.18.tar.bz2 && rm samtools-1.18.tar.bz2 && \
cd samtools-1.18 && \
./configure --prefix=/opt && \
make && \
make install

ENV PATH="${PATH}:/opt/samtools-1.18"
