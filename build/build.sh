#!/bin/env bash

functions=( \
  f-help \
  f-build \
  f-build-project \
  f-docker-run \
)

function_desc=( \
  "Print the help" \
  "Build all projects and containers" \
  "Build a single project and container" \
  "Run the selected projects container" \
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

# component name is generated from project name
parent_project_name="k9b9-sck8s"
dockerhub_registry="k9b9/sck8s"
local_registry="localhost:5000"
base_path=`pwd`

f-build() {
  for p in ${projects[@]}; do
    project_name=$p
    printf "Building project and container for $project_name\n\n"    # (optional) move to a new line
    component_name=`python build/split-project-name.py $project_name`
    # my_img_id like 'k9b9-sck8s-config-v1'
    my_img_id="$parent_project_name-$component_name-v1"
    build_project
    build_container
  done
}

f-build-project() {
  for i in "${!projects[@]}"; do
    printf "   $i  ${projects[$i]}\n"
  done
  printf "\n"
  read -p "Project number:  " -r
  project_name=${projects[$REPLY]}
  printf "Building project and container for $project_name\n\n"    # (optional) move to a new line
  component_name=`python build/split-project-name.py $project_name`
  # my_img_id like 'k9b9-sck8s-config-v1'
  my_img_id="$parent_project_name-$component_name-v1"
  build_project
  build_container
}

build_project() {
  pushd $project_name
  PWD=`pwd`
  printf "$PWD\n"
  mvn --batch-mode --no-transfer-progress clean package -DskipTests
  popd
}

build_container() {
  printf "MY_IMG_ID=$my_img_id\n"
  pushd $project_name
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
  printf "Running container for $project_name on port $component_port\n\n"    # (optional) move to a new line
  # remove the current image
  docker rm $my_img_id
    # --env eureka.client.register-with-eureka=false \
    # --env eureka.client.fetch-registry=false \
  docker run \
    --name $my_img_id \
    -p $component_port:$component_port \
    $local_registry/$my_img_id
  docker ps
}

pick_project() {
  for i in "${!projects[@]}"; do
    printf "   $i  ${projects[$i]}\n"
  done
  printf "\n"
  read -p "Project number:  " -r
  project_name=${projects[$REPLY]}
  component_port=${ports[$REPLY]}
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
