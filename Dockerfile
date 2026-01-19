FROM rocker/r-ver:4.3.2
LABEL Name=chessanalysis Version=0.0.1

# Ensure a POSIX shell with proper TTY support and useful utilities for R
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	   bash \
	   fortune-mod \
	   ncurses-term \
	   rlwrap \
	&& rm -rf /var/lib/apt/lists/*

ENV SHELL=/bin/bash
ENTRYPOINT ["bash", "-lc", "fortune -a | cat"]
