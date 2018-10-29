#!/bin/sh

set -euo pipefail

host="unix:///var/run/host-docker.sock"

echo 5.1 get list of image layers
layers="$(cat layers.txt)"

echo 5.2 copying layers from host
docker -H $host save $layers | docker load

echo 5.3 done loading layers
