#!/bin/env bash

# This script assumes Bash 5 and Maven 3+ are installed locally

clear

functions=( \
  f-help \
  f-build-all \
  f-build-project \
  f-docker-run \
  f-docker-run-all \
  f-build-run \
  f-docker-stop-all \
  f-docker-zipkin \
)

function_desc=( \
  "Print the help" \
  "Build all projects and containers" \
  "Build a single project and container" \
  "Run the selected projects container" \
  "Run all project containers, in correct order" \
  "Build then run a single project/container in Docker" \
  "Stop all Docker containers in this project" \
  "Run Zipkin in Docker" \
)

f-build-all() {
  for i in "${!projects[@]}"; do
    set_project $i
    printf "Building project and container for $project_name\n\n"    # (optional) move to a new line
    build_project
    build_container
  done
}

f-build-run() {
  pick_project
  printf "Building project and container for $project_name\n\n"    # (optional) move to a new line
  build_project
  build_container
  docker_run
}

f-build-project() {
  pick_project
  printf "Building project and container for $project_name\n\n"    # (optional) move to a new line
  build_project
  build_container
}

build_project() {
  pushd $project_name
  PWD=`pwd`
  printf "$PWD\n"
  # manual clean
  rm -r ./target
  mkdir ./target
  mvn_cmd="mvn --batch-mode --no-transfer-progress package -DskipTests"
  $mvn_cmd
  ### Testing: this works, running maven build within a Docker on Mac
  # mvn_img="maven:3.6.3-adoptopenjdk-11"
  # docker run -it --rm \
  #   --name MVN_BUILD_$project_name \
  #   -v "$(pwd)":/usr/src/$project_name \
  #   -v "$HOME/.m2":/root/.m2 \
  #   -v "$PWD/target:/usr/src/$project_name/target" \
  #   -w /usr/src/$project_name \
  #   $mvn_img \
  #   $mvn_cmd
  popd
}

build_container() {
  printf "IMG_ID=$img_id\n"
  pushd $project_name
  cp $base_path/build/docker-bootstrap.properties ./target/bootstrap.properties
    # --tag $dockerhub_registry-$component_name-v1:latest \
  docker build \
    --tag $local_registry/$img_id:$img_version \
    --file $base_path/build/Dockerfile \
    .
  # docker login
  # docker push $dockerhub_registry-$component_name-v1:latest
  docker push $local_registry/$img_id:$img_version
  popd
}

f-docker-run() {
  pick_project
  docker_run
}

f-docker-run-all() {
  for i in "${!projects_startup_order[@]}"; do
    set_project $i
    docker_run
    sleep 5
  done
}

f-docker-stop-all() {
  for i in "${!projects_startup_order[@]}"; do
    set_project $i
    docker stop $component_name
    printf "Stopping: $component_name\n"
    sleep 2
  done
}

f-docker-zipkin() {
  docker run --name zipkin --network k9b9sck8s --hostname zipkin --rm -d -p 9411:9411 openzipkin/zipkin
}
# 
# Runs the currently selected project
# 
docker_run() {
  # don't start if running
  # if [[ "" != "$(docker ps | grep $component_name)" ]]; then
  #   printf "Already running $component_name on port $component_port\n\n"
  #   exit 0
  # fi
  # if container exists but isn't running then remove it so we are using latest image
  if [[ "" != "$(docker ps | grep $component_name)" ]]; then
    printf "Stopping $component_name on port $component_port\n\n"
    docker stop $component_name
    sleep 2
  fi
  printf "\nStarting container for $project_name on port $component_port\n"
  printf "\nImage = $local_registry/$img_id\n\n"
  # if network not exist, then create
  if [[ "" == "$(docker network ls | grep $docker_network_name)" ]]; then
    docker network create $docker_network_name
  fi

    # --hostname $component_name \
    # --env EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://disco:8761/eureka \
    # --env SPRING_CLOUD_CONFIG_URI=http://config:8090 \
  docker run \
    --name $component_name \
    --label $img_id \
    --network $docker_network_name \
    --detach \
    --rm \
    --env SPRING_PROFILES_ACTIVE=default \
    -p $component_port:$component_port \
    $local_registry/$img_id:$img_version
  # docker ps -a
}


source build/shared.sh