# SpringCloud-Kubernetes

A basic Spring Cloud microservices architecture running on Kubernetes (and also locally for development). Where possible, Spring components have been used. For ease of development, the project code is organized into a monorepo containg multiple projects/components.

### Assumptions
- Mac/Linux: All scripts are written for Mac/Linux. Build/_builder,kube,shared should all be easy to port to PC. Contribs welcome.
- Minikube: Must be running minikube to host the Kubernetes cluster.
- Docker: Must have Docker installed for building containers
- Local Registry: Must run local Docker registry node

### Features

    API Gateway Service         - Spring Cloud Gateway
    Discovery Service/Dashboard - Spring Cloud Eureka
    Gateway Load Balancing      - API Gateway load balances between instances 
                                  of service
    Client-Side Load Balancing  - Inter-component REST requests load balance 
                                  between instances of microservice
    Hystrix Circuit Breakers    - Fallback responses for non-responsive microservices
    Hystrix Dashboard           - Working via direct access, not gateway (due to Hystrix) 
                                  (Replace in next version)
    UI Service                  - Web UI
    Config Service              - All components pull config from config server 
                                  (Not Working as designed, needs testing)
                                  Should be replaced with Kubernetes ConfigMap
    Zipkin                      - Tracing
    Kubernetes Dashbaord        - Open via build script, look for Pod 'sck8s'. 
    Build Script                - Interactive build script makes it easy to build and 
                                  deploy the system (bash build/build.sh)
                                  Three dots > Logs.
    Cross-Platform Builder      - Run build/_builder.sh to get a Docker container which
                                  can build the project (no need to install/config Java or Maven)
    Kubernetes Script           - Interactive script to run common k8s commands

### Services, Ports and Startup Order
    svc name      port   srvr name  startup order
    ---------------------------------------------
    gateway-svc   8080   gateway    2
    ui-svc        8082   ui         -
    report-svc    8084   report     -
    valid-svc     8086   valid      -
    htxdbd-svc    8088   htxdbd     -
    disco-svc     8761   disco      1
    config-svc    8888   config     3
    zipkin        9411   zipkin     -

## Important Notes
1. Config Server Master Branch in GitHub: New GitHub repos no longer have a 'master' branch, but use a 'main' branch. This will cause the Config Server to be unable to pull from GitHub, unless the 'spring.cloud.config.server.git.default-label' is set to 'main' (as of Feb 2021).
1. Bootstrap.yml: Now ignored unless the dependency 'spring-cloud-starter-bootstrap' is in the pom

## Install Docker Desktop
Web search it.

## Install Minikube

This project depends on Minkube. Install [MiniKube](https://minikube.sigs.k8s.io/docs/start/) or use this [install guide](https://gist.github.com/kevin-smets/b91a34cea662d0c523968472a81788f7).
(kubectl is now configured to use "minikube" cluster and "default" namespace by default)

To start minikube and display the dashboard:
```
minikube start
minikube dashboard
```

## Install Local Container Registry

The build system assumes a local container registry server running. 
```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```
[Deploy instructions](https://docs.docker.com/registry/deploying/)

## Build the Project

From the root of the parent project (springcloud-kubernetes), run `bash build/_builder.sh` which builds and starts the 'builder' Docker container. The builder container provides a consistent build environment. From within the container run `bash build/build.sh`. The build script is interactive. The build script will build the jar and the container, by choosing the build project option followed by the option. Choose build all to start.

## Run the Project

### 3 Ways to Run

1. Run in Minikube, via the build/kube script. Zipkin runs in the pod automatically, and does not need to be manually started
1. Run in Docker via the build/build script. See the Docker section. See the Zipkin section (manual start)
1. Run locally via the IDE. The .vscode/launch.json file is included to simplify this process if using VS Code, and can also be used to show parameters. You could always manually build the jar and manually run it via the command line. See the Zipkin section (manual start). It's best to run the projects according to the startup order defined in the Ports and Startup Order section. Only the first 3 matter, the rest can be started in any order.

### Run on Minikube

This project is about Spring Cloud and Kubernetes, so this is the desired way to run.

Open a command line and run `minikube start`. Then open a new command line to run the following.

Run `bash build/_builder.sh` to launch the builder container, then `bash build/build.sh` and choose `f-build-all`. Then exit the builder container. The next connand will not run from within the builder container.

Run `bash build/kube.sh` (not from within the builder container!) and choose `f-cache-all`, then re-run and choose `f-kube-pod-redeploy`.
The cache-all function will copy all the containers from the local Docker registry into the minikube registry. From there all the containers are always loaded from local storage because the k8s/pod.yml lists all container's imagePullPolicy=Never (meaning never pull from remote, always use local.)
The pod-deploy function will run kubectl on the k8s/pod.yml and the k8s/service.yml config files.

Re-run `bash build/kube.sh` and choose `f-kube-dashboard`, which calls `minikube dashboard`. You should see a pod named *sck8s* and a service named *sck8s*.

Re-run `bash build/kube.sh` and choose `f-kube-service-open`, which calls `minikube service sck8s`. This will start a tunnel to minikube on an IP like '192.168.64.3', which will be referenced as <tunnel-ip> below, and then open your browser to the service URLs.

It will print something like:

|-----------|-------|--------------|---------------------------|
| NAMESPACE | NAME  | TARGET PORT  |            URL            |
|-----------|-------|--------------|---------------------------|
| default   | sck8s | disco/8761   | http://<tunnel-ip>:31761  | Eureka Discovery Server
|           |       | gateway/8080 | http://<tunnel-ip>:31080  | Spring Cloud Gateway Server
|-----------|-------|--------------|---------------------------|

In browser, visit the url disco/8761 (the Eureka Discovery Service), which should display the Eureka Dashboard, and visit the gateway/8080 url to show the Web UI (via the Gateway Service), with links to other components of the project which are also served via the Gateway Service. Start with the returned HTML page with the title Spring Boot + Kubernetes and go through the links. You may need to refresh a few times to allow the pod to fully deploy and the containers to register with Eureka.

### Links

#### Minikube

Running `minikube service` will open a tunnel to the cluster. This is the same location as if you did `docker exet -it minikube` or if you used the CLI button on the minikube container in Docker desktop, except then you will be in an environment that doesn't have a browser.

[Eureka Dashboard - Direct](http://<tunnel-ip>:31761)
[Eureka Dashboard - via Gateway](http://<tunnel-ip>:31080/disco)
[API Gateway Hystrix Stream](http://<tunnel-ip>:31080/actuator/hystrix.stream)
[Hystrix Dashboard - via Gateway](http://<tunnel-ip>:31080/hystrix/monitor?stream=http%3A%2F%2F<tunnel-ip>%3A31080%2Factuator%2Fhystrix.stream)
Hystrix Dashboard Gateway - Not functional. App does not have consistent servlet context (conflicts with '/ui' in gateway). Must expose through K8s.
[Zipkin via Gateway](http://localhost:31080/zipkin)

#### IDE or Docker: Localhost
If run via IDE or Docker, then the following localhost addresses will work.
[Eureka Dashboard - Direct](http://localhost:8761)
[Eureka Dashboard - via Gateway Proxy](http://localhost:8080/disco)
[API Gateway Hystrix Stream](http://localhost:8080/actuator/hystrix.stream)
[Hystrix Dashboard](http://localhost:8088/hystrix/monitor?stream=http%3A%2F%2Flocalhost%3A8080%2Factuator%2Fhystrix.stream)
Hystrix Dashboard Gateway - Not functional. App does not have consistent servlet context (conflicts with '/ui' in gateway). Must expose through K8s.
[Zipkin](http://localhost:9411)

## Docker

The Docker containers are built via the build script, choose *f-docker-run-all*. See the Building section.

Docker network name is set in build/build.sh to docker_network_name="host". All components are wired to use this network, which means their ports are available on localhost.

### Zipkin

The Zipkin runs as a simple Docker container. Run `build/_builder.sh` then `bash build/build.sh` and choose *f-docker-zipkin*.
Or run it from the command line:
```
docker run --name zipkin --network k9b9sck8s --hostname zipkin -d -p 9411:9411 openzipkin/zipkin
```

# Detailed Run and Test for Docker

See above for all these commands:
Install Docker
Install Docker Registry Locally
Run Zipkin on docker
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

# Misc Notes for Minikube

Install [MiniKube](https://minikube.sigs.k8s.io/docs/start/) or this [install guide](https://gist.github.com/kevin-smets/b91a34cea662d0c523968472a81788f7).
(kubectl is now configured to use "minikube" cluster and "default" namespace by default)
minikube start
minikube dashboard

```
minikube start --driver=docker
# or --driver=hyperkit
# or --driver=virtualbox

# optional: minikube config set driver hyperkit 
#(or docker or virtualbox)

bash build/build.sh

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

# show status of the pod
kubectl describe pod/sck8s -n default

# get a shell on minikube
docker exec -it minikube /usr/bin/bash

minikube delete
```
See: https://github.com/kubernetes/minikube/issues/9016
(To go back to docker use minikube start --driver=docker)
(drivers: virtualbox, docker, hyperkit)

# Results

## Config Server

Interesting post on [Config Server refresh strategies](https://soshace.com/spring-cloud-config-refresh-strategies/)

Also, @Scheduled or @PostContruct refresh can be done with:

```
class ... {

    @Autowired
    private ApplicationEventPublisher eventPublisher;

    @PostConstruct
    public void fireRefreshEvent() {
        eventPublisher.publishEvent(new RefreshEvent(this, "RefreshEvent", "Refreshing scope");
    }
}
```

The services valid-svc and report-svc are configured to use the Discovery Service to find the Config Server then pull values. 
The CtrlHello in valid-svc has @RefreshScope and a test value which comes from the Config Server.
Calling `curl -X GET  http://<ip>:<port>/valid/api/hello` prints `{"message":"Hello from valid-svc on port 41325 'ValueMissing'"}` where 'ValueMissing' is the default value. 
Make and update to the config on GitHub, then force a refresh on the valid service.
`curl -X POST http://<ip>:<port>/valid/actuator/refresh` and then retrieving the hello again with `curl -X GET  http://<ip>:<port>/valid/api/hello`, but didn't update.

Config server has things in common with Kubernetes ConfigMap, so most things should be done in ConfigMap, but there are places where Config Server can play a role, such as refreshing a container on the fly.

curl -X POST http://localhost:8086/valid/actuator/refresh
curl -X GET http://localhost:8086/valid/api/hello

