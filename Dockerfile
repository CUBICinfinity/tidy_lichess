# R Development Environment for tidy_lichess
FROM rocker/r-ver:4.3.2

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    r-base \
    git \
    curl \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    && rm -rf /var/lib/apt/lists/*

# Install R packages from CRAN
RUN R -e "install.packages(c('tidyverse', 'ggpmisc', 'cowplot', 'remotes'), repos='https://cloud.r-project.org/')"

# Install stockfish package from CRAN archive (removed from CRAN in 2023)
RUN R -e "install.packages('https://cran.r-project.org/src/contrib/Archive/stockfish/stockfish_1.0.0.tar.gz', repos=NULL, type='source')"

# Copy source code (but don't run it)
COPY . .

# Default to shell access
CMD ["/bin/bash"]
