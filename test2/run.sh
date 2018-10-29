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
start1=$(date +%s)
docker exec dind docker build .
build1=$(date +%s)
docker exec dind ./save-docker-layers.sh
save=$(date +%s)

echo 3. remove first docker container
docker kill dind

echo 4. spin up docker in docker container
docker run \
    -d --name dind --rm --privileged \
    -v /var/run/docker.sock:/var/run/host-docker.sock \
    -v $dir:$dir -w $dir \
    docker:dind

echo 5. do docker build 
start2=$(date +%s)
docker exec dind ./load-docker-layers.sh
load=$(date +%s)
docker exec dind docker build .
build2=$(date +%s)

echo 6. remove second docker container
docker kill dind

echo vital statistics...
echo initial build: $(($build1 - $start1))
echo save layers: $(($save - $build1))
echo load layers: $(($load - $start2))
echo second build: $(($build2 - $load))

