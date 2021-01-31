#!/bin/env bash

clear

functions=( \
  f-help \
  f-build \
  f-build-project \
  f-docker-run \
  f-docker-run-all \
)

function_desc=( \
  "Print the help" \
  "Build all projects and containers" \
  "Build a single project and container" \
  "Run the selected projects container" \
  "Run all project containers, in correct order" \
)

projects_startup_order=( \
  disco-svc \
  config-svc \
  gateway-svc \
  ui-svc \
  report-svc \
  valid-svc \
  htxdbd-svc \
)

projects=( \
  gateway-svc \
  ui-svc \
  report-svc \
  valid-svc \
  htxdbd-svc \
  config-svc \
  disco-svc \
)

ports=( \
  8080 \
  8082 \
  8084 \
  8086 \
  8088 \
  8090 \
  8761 \
)
# gateway-svc : 8080
# ui-svc      : 8082
# report-svc  : 8084
# valid-svc   : 8086
# htxdbd-svc  : 8088
# config-svc  : 8090
# disco-svc   : 8761
component_port=0

# component_name is generated from project name
parent_project_name="k9b9-sck8s"
dockerhub_registry="k9b9/sck8s"
docker_network_name="k9b9sck8s"
local_registry="localhost:5000"
base_path=`pwd`
project_name="empty"

f-build() {
  for i in "${!projects[@]}"; do
    set_project $i
    printf "Building project and container for $project_name\n\n"    # (optional) move to a new line
    build_project
    build_container
  done
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
  rm -r ./target
  mvn --batch-mode --no-transfer-progress clean package -DskipTests
  popd
}

build_container() {
  printf "MY_IMG_ID=$my_img_id\n"
  pushd $project_name
  cp $base_path/build/docker-bootstrap.properties ./target/bootstrap.properties
  docker build \
    --tag $dockerhub_registry:$my_img_id \
    --tag $local_registry/$my_img_id \
    --file $base_path/build/Dockerfile \
    .
  docker push $dockerhub_registry:$my_img_id
  docker push $local_registry/$my_img_id
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
    sleep 2
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
# 
# Runs the currently selected project
# 
docker_run() {
  # don't start if running
  if [[ "" != "$(docker ps | grep $my_img_id)" ]]; then
    printf "Already running $project_name on port $component_port\n\n"
    exit 0
  fi
  printf "\nStarting container for $project_name on port $component_port\n"
  printf "\nImage = $local_registry/$my_img_id\n\n"
  # if container exists but isn't running then remove it so we are using latest image
  if [[ "" != "$(docker ps -a | grep $component_name)" ]]; then
    docker rm $component_name
  fi
  # if network not exist, then create
  if [[ "" == "$(docker network ls | grep $docker_network_name)" ]]; then
    docker network create $docker_network_name
  fi
    # --env eureka.client.register-with-eureka=false \
  docker run \
    --name $component_name \
    --label $my_img_id \
    --network $docker_network_name \
    --env SPRING_PROFILES_ACTIVE=default,docker \
    --env EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://disco:8761/eureka \
    --env SPRING_CLOUD_CONFIG_URI=http://config:8090 \
    --detach \
    -p $component_port:$component_port \
    $local_registry/$my_img_id
  # docker ps -a
}

pick_project() {
  for i in "${!projects[@]}"; do
    printf "   $i  ${projects[$i]}\n"
  done
  printf "\n"
  read -p "Project number:  " -r
  set_project $REPLY
}
# 
# Sets globals based on index in project array
# 
set_project() {
  project_name=${projects[$1]}
  component_port=${ports[$1]}
  component_name=`python build/split-project-name.py $project_name`
  # my_img_id like 'k9b9-sck8s-config-v1'
  my_img_id="$parent_project_name-$component_name-v1"
}

f-help() {
  # printf `cat build/help.txt\n`
  for i in "${!functions[@]}"; do
    f_name=${functions[$i]}
    f_desc=${function_desc[$i]}
    printf "   $i  $f_name - $f_desc\n"
  done
  printf "\n"
}

if [ ! -z "$1" ]; then
  f-action $1
  exit 0
else
  printf "\nEnter the number of the function and press Enter :\n"
  f-help

  read -p "Function number:  " -r
  printf "Running function ${functions[$REPLY]}\n\n"    # (optional) move to a new line
  ${functions[$REPLY]}
fi
