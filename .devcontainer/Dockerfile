FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    software-properties-common \
    dirmngr \
    gnupg \
    ca-certificates \
    wget \
    git \
    build-essential \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libjpeg-dev \
    libpng-dev \
    gfortran \
    locales \
    procps \
    bash \
 && rm -rf /var/lib/apt/lists/*

# Add CRAN repo and install R so it's available at build time (/usr/bin/R)
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 51716619E084DAB9 || true \
 && add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/" \
 && apt-get update \
 && apt-get install -y --no-install-recommends r-base r-base-dev \
 && rm -rf /var/lib/apt/lists/*

# Install renv so postCreateCommand can use it if needed
RUN Rscript -e "options(repos='https://cloud.r-project.org'); if (!requireNamespace('renv', quietly=TRUE)) install.packages('renv')"

WORKDIR /workspaces/chess_analysis
