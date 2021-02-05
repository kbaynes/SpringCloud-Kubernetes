#!/bin/env bash

# shared between build.sh and kube.sh

# This script assumes Bash 5 and Maven 3+ are installed locally

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
pod_name=$parent_project_name
dockerhub_registry="k9b9/sck8s"
docker_network_name="host"
local_registry="localhost:5000"
img_version="v1"
base_path=`pwd`
project_name="empty"
padded_str=""

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
  component_name=`python3 build/split-project-name.py $project_name`
  # img_id like 'k9b9-sck8s-config-v1'
  img_id="$parent_project_name-$component_name"
}

pad_string() {
  padded_str=$1
  maxlen=$2
  while ((${#padded_str} < $maxlen)); do 
    padded_str+=" "
  done
}

f-help() {
  # printf `cat build/help.txt\n`
  for i in "${!functions[@]}"; do
    local f_name=${functions[$i]}
    pad_string $f_name 20
    local f_desc=${function_desc[$i]}
    printf "   $i  $padded_str - $f_desc\n"
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
