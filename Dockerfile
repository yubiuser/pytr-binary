# syntax=docker/dockerfile:1
ARG debian_version=slim-bullseye
ARG python_version=3.10
ARG pytr_tag=v0.4.10

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


# Install pytr dependencies from source
RUN python3 -m pip install .

# Install playwright chromium
# Not needed for pytr >0.4.10, with the new v2 login method
# RUN PLAYWRIGHT_BROWSERS_PATH=0 python3 -m playwright install chromium

WORKDIR /pytr/pytr

# Build the executable file (-F) and strip debug symbols
# Use pythons optimize flag (-OO) to remove doc strings, assert statements, sets __debug__ to false
# (not possible with webchanges, no cli output otherwise)
#RUN python3 -OO -m PyInstaller -F --strip --name pytr --add-data ./awswaf/webgl.json:./pytr/awswaf/ ./main.py
RUN python3 -OO -m PyInstaller -F --strip --name pytr ./main.py

FROM scratch AS export
COPY --from=builder /pytr/pytr/dist/pytr /pytr
