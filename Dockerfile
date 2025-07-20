# syntax=docker/dockerfile:1
ARG debian_version=slim-bullseye
ARG python_version=3.10
ARG pytr_tag=v0.4.3

FROM python:${python_version}-${debian_version} AS builder
ARG pytr_tag

RUN apt-get update && \
    apt-get --no-install-recommends install -y \
    binutils \
    gcc \
    libc-dev \
    libffi-dev \
    upx-ucl \
    zlib1g-dev

# Update pip, setuptools and wheel, install pyinstaller
RUN python3 -m pip install --upgrade \
    pip \
    setuptools \
    wheel \
    && python3 -m pip install pyinstaller

ADD https://github.com/pytr-org/pytr.git#${pytr_tag} /pytr
WORKDIR /pytr


# Install from source
RUN python3 -m pip install .

WORKDIR /pytr/pytr
# monkey patch: pyinstaller does not support 'site' module
# so replace all exit() calls with sys.exit() and import the sys module
# account.py already imports sys
RUN sed -i 's/exit(/sys.exit(/g' *.py
RUN sed -i '/import signal/a import sys' main.py
RUN sed -i '/import logging/a import sys' __main__.py
RUN sed -i '1s/^/import sys\n/' dl.py


# Build the executable file (-F) and strip debug symbols
# Use pythons optimize flag (-OO) to remove doc strings, assert statements, sets __debug__ to false
# (not possible with webchanges, no cli output otherwise)
RUN python3 -OO -m PyInstaller -F --strip --name pytr ./main.py


FROM scratch AS export
COPY --from=builder /pytr/pytr/dist/pytr /pytr
