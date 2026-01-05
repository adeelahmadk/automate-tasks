#!/usr/bin/env bash

#################################################
# Make sure to place Dockerfile and other config
# files at the location of this script.
#################################################

# VARS: image, tag, and container names
IMG="nginx-proxy-wp"
TAG="alpine"
CONT_NAME="wp-proxy"

# Build image if not exists
if [ -z $(docker images -q "${IMG}:${TAG}") ]; then
  echo "image ${IMG}:${TAG} not found, building..."
  docker build -t "${IMG}:${TAG}" .
  printf "\nDone building image!\n"
  sleep 1
fi

## If container already exists then make sure it's running
if docker ps -aq -f name="${CONT_NAME}" -f "status=running" | grep -q . ; then
  # just inform if container already running
  echo "container ${CONT_NAME} already running:"
  docker ps -a \
    --filter "name=${CONT_NAME}" \
    --format "{{.ID}} | {{.Image}} | {{.State}} | {{.Status}}"
  exit 0
elif docker ps -aq -f name="${CONT_NAME}" -f "status=exited" | grep -q . ; then
  # start if the container is not running
  echo "container ${CONT_NAME} exists, trying to start..."
  docker container start "${CONT_NAME}"
  exit 0
fi

## start a new container from our image
echo "spinning up ${CONT_NAME}..."
docker run -d \
  --restart=unless-stopped \
  --add-host=host.docker.internal:host-gateway \
  --name "${CONT_NAME}" \
  -p 80:80 \
  "${IMG}:${TAG}"

