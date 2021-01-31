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

The Docker containers are built via the build script . See the Building section.

Docker network name is set in build/build.sh to docker_network_name="k9b9sck8s". All components are wired to use this network.

### Zipkin

The Zipkin runs as a simple Docker container. Run it from the command line:

`docker run --name zipkin --network k9b9sck8s -d -p 9411:9411 openzipkin/zipkin`




