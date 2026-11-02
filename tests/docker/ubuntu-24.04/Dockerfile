# Approximates a fresh Ubuntu 24.04 desktop: only what a new install already ships
# (sudo, git, python3, certs). Everything else must come from the dotfiles.
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
	&& apt-get install -y --no-install-recommends sudo git python3 ca-certificates \
	&& rm -rf /var/lib/apt/lists/* \
	&& echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ubuntu \
	&& chmod 0440 /etc/sudoers.d/ubuntu

# Non-root user with sudo, like the first account on a real machine.
USER ubuntu
WORKDIR /home/ubuntu
ENV LANG=C.UTF-8 TERM=xterm-256color

# The repo is mounted read-only from the host (different owner), and the test
# clones private submodules from the host's local copy, which git blocks by
# default for submodules. Test image only; never set this on a real machine.
RUN git config --global --add safe.directory '*' \
	&& git config --global protocol.file.allow always
