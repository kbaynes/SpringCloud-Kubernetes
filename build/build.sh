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
  f-cache-all \
  f-cache-project \
  f-kube-redeploy-pod \
  f-kube-pod-shell \
  f-kube-dashboard \
)

function_desc=( \
  "Print the help" \
  "Build all projects and containers" \
  "Build a single project and container" \
  "Run the selected projects container" \
  "Run all project containers, in correct order" \
  "Build then run a single project/container in Docker" \
  "Stop all Docker containers in this project" \
  "Transfer all images to Minikube images cache" \
  "Transfer project image to Minikube images cache" \
  "Re-deploy the Pod to Minikube (delete/apply)" \
  "Get a shell on the Pod" \
  "Open the Kubernetes dashboard" \
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
parent_project_name="sck8s"
dockerhub_registry="k9b9/sck8s"
docker_network_name="k9b9sck8s"
local_registry="localhost:5000"
img_version="v1"
base_path=`pwd`
project_name="empty"

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

f-cache-project() {
  pick_project
  cache_project
  cache_reload
  cache_list
}

f-cache-all() {
  for i in "${!projects[@]}"; do
    set_project $i
    cache_project
  done
  cache_reload
  cache_list
}

cache_project() {
  printf "minikube cache add $local_registry/$img_id:$img_version \n"
  hasImg=`minikube cache list | grep $local_registry/$img_id:$img_version`
  if [[ "$hasImg" != "" ]]; then
    minikube cache delete $local_registry/$img_id:$img_version
  fi
  minikube cache add $local_registry/$img_id:$img_version
}

cache_reload() {
  printf "#### minikube cache reload ... \n"
  minikube cache reload
}

cache_list() {
  printf "#### minikube cache list : \n"
  minikube cache list
}

f-kube-redeploy-pod() {
  kubectl delete pod sck8s
  kubectl apply -f $base_path/k8s/pod.yml
  kubectl delete service sck8s
  kubectl apply -f $base_path/k8s/service.yml 
}

f-kube-pod-shell() {
  kubectl exec --stdin --tty sck8s -- /bin/sh
}

f-kube-dashboard() {
  minikube dashboard
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

  docker run \
    --name $component_name \
    --label $img_id \
    --network $docker_network_name \
    --hostname $component_name \
    --env SPRING_PROFILES_ACTIVE=default,docker \
    --env EUREKA_CLIENT_SERVICEURL_DEFAULTZONE=http://disco:8761/eureka \
    --env SPRING_CLOUD_CONFIG_URI=http://config:8090 \
    --detach \
    --rm \
    -p $component_port:$component_port \
    $local_registry/$img_id:$img_version
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
  # img_id like 'k9b9-sck8s-config-v1'
  img_id="$parent_project_name-$component_name"
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
