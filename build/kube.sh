#!/bin/env bash

# Kubernetes commands for Mac/Linux

# This script assumes Bash 5, Minikube and kubectl are installed locally

clear

functions=( \
  f-help \
  f-kube-start \
  f-kube-delete \
  f-kube-dashboard \
  f-cache-all \
  f-cache-project \
  f-kube-pod-redeploy \
  f-kube-pod-shell \
  f-kube-pod-describe \
  f-kube-service-urls \
  f-kube-service-open \
)

function_desc=( \
  "Print the help" \
  "Start Minikube" \
  "Delete Minikube" \
  "Open the Kubernetes dashboard" \
  "Transfer all images to Minikube images cache" \
  "Transfer project image to Minikube images cache" \
  "Re-deploy the Pod to Minikube (delete/apply)" \
  "Get a shell on the Pod" \
  "Describe the Pod" \
  "Show service urls" \
  "Open service urls" \
)

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

f-kube-pod-redeploy() {
  if [[ "" != "kubectl describe pod $pod_name | grep \"Name:[ \t]+$pod_name\"" ]]; then
    kubectl delete pod $pod_name
  fi
  kubectl apply -f $base_path/k8s/pod.yml
  if [[ "" != "kubectl describe service $pod_name | grep \"Name:[ \t]+$pod_name\"" ]]; then
    kubectl delete service $pod_name
  fi
  kubectl apply -f $base_path/k8s/service.yml 
  kubectl describe pods
}

f-kube-pod-shell() {
  kubectl exec --stdin --tty $pod_name -- /bin/sh
}

f-kube-pod-describe() {
  kubectl describe pod sck8s
}

f-kube-start() {
  minikube start
}

f-kube-delete() {
  printf "Will delete Minikube in 10 seconds... Press ctrl + c to cancel\n"
  sleep 10
  minikube delete
}

f-kube-dashboard() {
  minikube dashboard
}

f-kube-service-urls() {
  minikube service --url $pod_name
}

f-kube-service-open() {
  minikube service $pod_name
}

source build/shared.sh