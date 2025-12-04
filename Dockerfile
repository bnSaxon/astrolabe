# Dockerfile
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. System dependencies for astrometry.net build
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    swig \
    pkg-config \
    libcfitsio-dev \
    libnetpbm10-dev \
    netpbm \
    libpng-dev \
    libjpeg-dev \
    zlib1g-dev \
    wcslib-dev \
    python3 \
    python3-dev \
    python3-numpy \
    ca-certificates \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 2. Clone astrometry.net
WORKDIR /opt
RUN git clone https://github.com/dstndstn/astrometry.net.git

WORKDIR /opt/astrometry.net

# 3. Build and install astrometry.net
# You can customize INSTALL_DIR via 'make install INSTALL_DIR=/path'
RUN make && make py && make extra && \
    make install

# 4. Create a default config that looks for index files in /data/index
# NOTE: We do not download any indexes in the image; they are expected
# to be provided at runtime via a mounted volume.
RUN mkdir -p /data/index && \
    if [ -f /etc/astrometry.cfg ]; then mv /etc/astrometry.cfg /etc/astrometry.cfg.bak; fi && \
    printf "add_path /data/index\n" > /etc/astrometry.cfg

# 5. Add a helper script for optional index download
COPY download_indexes.sh /usr/local/bin/download_astrometry_indexes
RUN chmod +x /usr/local/bin/download_astrometry_indexes

# 6. Set a reasonable default working directory
WORKDIR /data

# 7. Put astrometry binaries in PATH (usually installed to /usr/local/bin already)
ENV PATH="/usr/local/bin:${PATH}"

# Default entrypoint: just a shell, so user can run solve-field or helper scripts
ENTRYPOINT ["/bin/bash"]

