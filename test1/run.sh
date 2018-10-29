#!/bin/bash

set -euo pipefail

dir="$(cd "$(dirname $0)"; pwd)"

echo 1. spin up docker in docker container
docker run \
    -d --name dind --rm --privileged \
    -v /var/run/docker.sock:/var/run/host-docker.sock \
    -v $dir:$dir -w $dir \
    docker:dind

echo 2. do docker build 
docker exec dind sh -c '
    docker build .
    ./save-docker-layers.sh
'

echo 3. remove first docker container
docker kill dind

echo 4. spin up docker in docker container
docker run \
    -d --name dind --rm --privileged \
    -v /var/run/docker.sock:/var/run/host-docker.sock \
    -v $dir:$dir -w $dir \
    docker:dind

echo 5. do docker build 
docker exec dind sh -c '
    ./load-docker-layers.sh
    docker build .
'

echo 6. remove second docker container
docker kill dind
