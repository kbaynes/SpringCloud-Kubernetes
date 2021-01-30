# SpringCloud-Kubernetes
A basic Spring Cloud microservices architecture running on Kubernetes (and also locally for development). Organized in a monorepo containg multiple projects/components.

Features:
API Gateway Service - Spring Cloud Gateway
Discovery Service w/ Dashboard - Spring Cloud Eureka
Gateway Load Balancing - API Gateway load balances between instances of service
Client-Side Load Balancing - Inter-component REST requests load balance between instances of microservice
Circuit Breakers - Fallback responses for non-responsive microservices
Hystrix Dashboard - Working via direct access, not gateway (due to Hystrix)
UI Service - Web UI
Config Service - All components pull config from config server

### Links
#### Local
Run all of the services locally, then:
[Eureka Direct](http://localhost:8761)
[Eureka Gateway](http://localhost:8080/disco)
[API Gateway Hystrix Stream](http://localhost:8080/actuator/hystrix.stream)
[Hystrix Dashboard](http://localhost:8088/hystrix/monitor?stream=http%3A%2F%2Flocalhost%3A8080%2Factuator%2Fhystrix.stream)
Hystrix Dashboard Gateway - Not functional. App does not have consistent servlet context (conflicts with '/ui' in gateway). Must expose through K8s.

gateway-svc : 8080
ui-svc      : 8082
report-svc  : 8084
valid-svc   : 8086
htxdbd-svc  : 8088
config-svc  : 8090
disco-svc   : 8761

