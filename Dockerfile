# Based on https://github.com/lukechilds/docker-electrumx
FROM python:3.8-alpine3.13

COPY ./bin /usr/local/bin

ARG VERSION=1.16.0

RUN chmod a+x /usr/local/bin/* && \
    apk add --no-cache --virtual .build-deps git build-base openssl && \
    apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing rocksdb-dev && \
    pip install --no-cache-dir --no-binary ':all:' --compile aiohttp pylru websockets python-rocksdb uvloop ujson && \
    git clone -b $VERSION https://github.com/spesmilo/electrumx.git && \
    cd electrumx && \
    sed -i "s/'plyvel',//" setup.py && \
    python setup.py install && \
    apk del .build-deps rocksdb-dev && \
    rm -rf /tmp/*

ENV HOME /data
ENV ALLOW_ROOT 1
ENV DB_DIRECTORY /data
ENV SERVICES=ssl://:50002,wss://:50004,rpc://0.0.0.0:8000
ENV SSL_CERTFILE ${DB_DIRECTORY}/electrumx.crt
ENV SSL_KEYFILE ${DB_DIRECTORY}/electrumx.key
ENV HOST ""
WORKDIR /data

EXPOSE 50002 50004 8000

CMD ["init"]
