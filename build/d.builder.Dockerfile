# builds a base image for Java Apps
# includes mysql-client, Python3, and AWS CLI

# base alpine
FROM alpine:3
RUN apk update
# JDK 11
RUN apk --no-cache add openjdk11 \
	--repository=http://dl-cdn.alpinelinux.org/alpine/edge/community
# add mysql-client
RUN apk add --no-cache mysql-client
# install Maven
RUN apk add --no-cache curl tar bash procps

# Downloading and installing Maven
# 1- Define a constant with the version of maven you want to install
ARG MAVEN_VERSION=3.6.3         
# 2- Define a constant with the working directory
ARG USER_HOME_DIR="/root"
# 4- Define the URL where maven can be downloaded from
ARG MVN_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz 
# 5- Create the directories, download maven, validate the download, install it, remove downloaded file and set links
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downlaoding maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz $MVN_URL \
  \
  && echo "Unzipping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn
# 6- Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"

# add AWS CLI
RUN apk add --no-cache \
				python3 \
				py3-pip \
				less \
				bash \
				docker \
				openrc \
		&& pip3 install --upgrade pip \
		&& pip3 install \
				awscli \
		&& rm -rf /var/cache/apk/* \
		&& mkdir -p /project_root 
# test aws install
RUN aws --version
RUN rc-update add docker boot
# COPY ./mytask/* /mytask/
# Do not copy in, link it in
# COPY ./app.jar /mytask/
# RUN chmod a+x /mytask/mytask.sh 
# && \
# 		chmod a+x /mytask/get-secret.sh && \
# 		chmod a+x /mytask/parse-secret.py
# COPY /mytask ./
# RUN chmod +x /mytask
# CMD ["service docker start"]
# ENTRYPOINT ["bash build/buildscript.sh]

WORKDIR /project_root

# COPY pom.xml /build/
# COPY src /build/src/
# COPY release /build/release/
# RUN bash release/build.sh