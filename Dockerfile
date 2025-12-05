FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. System dependencies for astrometry.net build
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    imagemagick \
    file \
    swig \
    saods9 \
    libbz2-dev \
    pkg-config \
    libcfitsio-dev \
    libcairo2-dev \
    libnetpbm10-dev \
    netpbm \
    libpng-dev \
    libjpeg-dev \
    zlib1g-dev \
    wcslib-dev \
    python3 \
    python3-dev \
    python3-pip \
    python3-scipy \
    python3-pil \
    python3-setuptools \
    python3-numpy \
    ca-certificates \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN pip install astropy

# 2. Clone astrometry.net
WORKDIR /opt
RUN git clone https://github.com/dstndstn/astrometry.net.git

WORKDIR /opt/astrometry.net

# 3. Build and install astrometry.net
RUN make && make py && make extra && \
    make install

# We need to tell astrometry to search in astrolabe/data/index for index files
COPY config/astrometry.cfg /usr/local/astrometry/etc/astrometry.cfg

ENV PATH="/usr/local/astrometry/bin:${PATH}"

# Make relevant folders inside the astrolabe directory
RUN mkdir -p /astrolabe/data/index && \
    mkdir -p /astrolabe/data/input_images && \
    mkdir -p /astrolabe/data/output_solves && \
    mkdir -p /astrolabe/scripts


COPY scripts/ /astrolabe/scripts
RUN chmod -R +x /astrolabe/scripts

WORKDIR /astrolabe

ENTRYPOINT ["/bin/bash"]

