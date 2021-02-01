#!/bin/env bash

# The following test works: creating a 'builder' Docker image to run build the build script
# It works fine on Mac and the container docker.sock is shared with the parent
# Need to test to see if we can rewrite this script to run on Windows
# In theory this runs on Windows too (once re-written for batch, but docker calls are same)

base_path=`pwd`
local_registry="localhost:5000"
img_name="builder"
img_version="v1"
build_cmd="bash build/buildscript.sh"

docker build \
  --tag $local_registry/$img_name:$img_version \
  --file $base_path/build/d.builder.Dockerfile \
  .
# docker push $dockerhub_local_registry:$my_img_name
docker push $local_registry/$img_name:$img_version

# cache all maven files outside of the container, in the normal dir
[[ -d $HOME/.m2 ]] || mkdir $HOME/.m2

# the docker.sock line allows us to run docker commands (such as 'docker build') inside this docker container
docker run -it --rm \
  --name $img_name \
  --label $img_name \
  -v "$(pwd)":/project_root \
  -v "$HOME/.m2":/root/.m2 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /project_root \
  $local_registry/$img_name:$img_version
