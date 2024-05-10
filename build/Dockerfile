ARG PYTHON_VERSION=3.9-slim

FROM python:${PYTHON_VERSION}
LABEL maintainer="kaduhiro <github@kaduhiro.com>"

RUN apt-get update \
    && apt-get install -y tini curl libpcap-dev

ENV PYTHONUNBUFFERED=1

RUN pip install --upgrade pip
RUN pip install --upgrade setuptools
RUN pip install --upgrade amazon-dash

RUN mkdir /app

RUN rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENTRYPOINT ["/usr/bin/tini", "--"]
