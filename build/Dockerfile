# base alpine
FROM alpine:3
# JDK 11
RUN apk --no-cache add openjdk11 \
	--repository=http://dl-cdn.alpinelinux.org/alpine/edge/community \
		&& rm -rf /var/cache/apk/* \
		&& mkdir -p /srv/app \
    && chmod +x /srv/app
ARG JAR_FILE=target/*.jar
COPY ${JAR_FILE} /srv/app/app.jar
# COPY target/bootstrap.properties /srv/app/application.properties
RUN chmod +x /srv/app/app.jar
ENTRYPOINT ["java","-jar","/srv/app/app.jar"]
# ENTRYPOINT ["java","-jar","/srv/app/app.jar", \
# 	"-cp","/srv/app/", \
# 	"--spring.config.location=file:/srv/app/bootstrap.properties"]
WORKDIR /srv/app