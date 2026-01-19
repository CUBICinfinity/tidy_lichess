#!/bin/bash
set -e
# Update and install system packages (Ubuntu)
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential wget git ca-certificates \
  libcurl4-openssl-dev libssl-dev libxml2-dev gfortran \
  libjpeg-dev libpng-dev

# Ensure R is available
if ! command -v R >/dev/null 2>&1; then
  echo "R not found. Install R (e.g. apt install r-base) then re-run this script."
  exit 1
fi

# Install renv and restore project libraries if lockfile exists
Rscript -e "options(repos='https://cloud.r-project.org'); if (!requireNamespace('renv', quietly=TRUE)) install.packages('renv')"
if [ -f renv.lock ]; then
  Rscript -e "renv::restore(prompt=FALSE)"
else
  echo "No renv.lock found. Initialize renv with Rscript -e 'renv::init()' on a machine with the packages installed, then renv::snapshot() and commit renv.lock."
fi
