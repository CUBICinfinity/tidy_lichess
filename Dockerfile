# This is a basic script for running the application with Docker.
# I thought that it would be possible to run Stockfish on the GPU as well as the CPU, which is why I test using CUDA. 
# Unfortunately, converting Stockfish to work on a GPU is not a simple task.

FROM rocker/r-ver:4.2.1-cuda10.1

RUN mkdir /home/tidy_lichess && mkdir /home/output

# ToDo: Use of `checkpoint` and/or `remotes`.
RUN R -e "install.packages(c('tidyverse', 'stockfish', 'parallel', 'torch')); \
  torch::install_torch()"

COPY docker_test.R /home/tidy_lichess/docker_test.R

CMD cd /home/tidy_lichess \
  && R -e "source('/home/tidy_lichess/docker_test.R')" \
  && mv /home/tidy_lichess/test.csv /home/output/test.csv

# # makes /output a shared volume. This only works in PowerShell. Run the following:
# mkdir ~/tidy_lichess/output
# docker build --build-arg -t tidy_lichess .
# docker run -v "$(pwd)\tidy_lichess\output:/home/output" tidy_lichess