#!/bin/sh

set -euo pipefail

host="unix:///var/run/host-docker.sock"

layers="$(docker images -q | xargs -n 1 docker history -q | grep -v missing)"

echo 2.1 saving image layers to host docker socket
docker save $layers | docker -H $host load

echo 2.2 saving list of image layers to host docker
echo "$layers" > layers.txt

echo 2.3 done saving image layers
