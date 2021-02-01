# SpringCloud-Kubernetes

A basic Spring Cloud microservices architecture running on Kubernetes (and also locally for development). Where possible, Spring components have been used. Organized in a monorepo containg multiple projects/components.

### Features:

API Gateway Service - Spring Cloud Gateway
Discovery Service w/ Dashboard - Spring Cloud Eureka
Gateway Load Balancing - API Gateway load balances between instances of service
Client-Side Load Balancing - Inter-component REST requests load balance between instances of microservice
Circuit Breakers - Fallback responses for non-responsive microservices
Hystrix Dashboard - Working via direct access, not gateway (due to Hystrix)
UI Service - Web UI
Config Service - All components pull config from config server

## Running

This project can be run in Docker via the build script. See the Building section. See the Docker section.

This project can be run locally via the IDE. The .vscode/launch.json file is included to simplify this process if using VS Code, and can also be used to show parameters. You could always manually build the jar and manually run it via mvn and the command line.

The only exception is Zipkin, which is simply run as a Docker container. See the Zipkin section below.

## Building

From the root of the parent project (springcloud-kubernetes), run `bash build/build.sh`. The build script is interactive. The build script will build the jar and the container, by choosing the build project option followed by the option.

### Building Containers

See the Building section.

The build system assumes a local registyry server running. You can easily run your own container registry locally:

[docker run -d -p 5000:5000 --restart=always --name registry registry:2](https://docs.docker.com/registry/deploying/)

### Links
#### Local
Run all of the services locally, then:
[Eureka Direct](http://localhost:8761)
[Eureka Gateway](http://localhost:8080/disco)
[API Gateway Hystrix Stream](http://localhost:8080/actuator/hystrix.stream)
[Hystrix Dashboard](http://localhost:8088/hystrix/monitor?stream=http%3A%2F%2Flocalhost%3A8080%2Factuator%2Fhystrix.stream)
Hystrix Dashboard Gateway - Not functional. App does not have consistent servlet context (conflicts with '/ui' in gateway). Must expose through K8s.
[Zipkin](http://localhost:9411)

### Ports
    svc name      port   srvr name
    ------------------------------
    gateway-svc   8080   gateway
    ui-svc        8082   ui
    report-svc    8084   report
    valid-svc     8086   valid
    htxdbd-svc    8088   htxdbd
    config-svc    8090   config
    disco-svc     8761   disco

## Docker

The Docker containers are built via the build script. See the Building section.

Docker network name is set in build/build.sh to docker_network_name="k9b9sck8s". All components are wired to use this network.

### Zipkin

The Zipkin runs as a simple Docker container. Run it from the command line:

`docker run --name zipkin --network k9b9sck8s --hostname zipkin -d -p 9411:9411 openzipkin/zipkin`

---

MiniKube Installation on Mac

https://gist.github.com/kevin-smets/b91a34cea662d0c523968472a81788f7

---

# Detailed Run and Test for Docker

Install Docker
Install Docker Registry Locally
Install Zipkin
Build all projects/containers
Run all projects/containers
Open UI home page
Open Eureka Discovery home page
Open Zipkin home page
Run the Exercise Test
• Check the Zipkin output
• 
Stop the Valid Service
Check the Valid Hello endpoint to see the circuit breaker working

# Detailed Run and Test for MiniKube

Install MiniKube
(kubectl is now configured to use "minikube" cluster and "default" namespace by default)
minikube start
minikube dashboard

```
minikube start --driver=docker
# or --driver=hyperkit
# optional: minikube config set driver hyperkit (or docker)
# create a hello-node to test
kubectl create deployment disco-node --image=localhost:5000/k9b9-sck8s-disco-v1
# expose hello-node on 9080
kubectl expose deployment disco-node --type=LoadBalancer --port=8761
minikube service disco-node
# show IP
kubectl get node -o wide
# show the hello-node in browser

kubectl delete service disco-node
kubectl delete deployment disco-node

To deploy the pod (sck8s):

kubectl apply -f k8s/pod.yml
kubectl exec --stdin --tty sck8s -- /usr/bin/bash

# get a shell on minikube
docker exec -it minikube /usr/bin/bash

minikube delete
```
See: https://github.com/kubernetes/minikube/issues/9016
(To go back to docker use minikube start --driver=docker)
