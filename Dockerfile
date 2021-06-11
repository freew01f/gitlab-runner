FROM gitlab/gitlab-runner:alpine

ENV LANG C.UTF-8

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

# jdk8 安装
# add a simple script that can auto-detect the appropriate JAVA_HOME value
# based on whether the JDK or only the JRE is installed
RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u275
ENV JAVA_ALPINE_VERSION 8.275.01-r0

RUN set -x \
	&& apk add --no-cache \
		openjdk8="$JAVA_ALPINE_VERSION" \
	&& [ "$JAVA_HOME" = "$(docker-java-home)" ]

# maven 安装
RUN apk add --no-cache maven
COPY settings.xml /root/.m2/settings.xml

# nodejs 安装
RUN apk add --no-cache curl tar nodejs nodejs-npm openssh-keygen openssh sshpass \
&& npm install -g cnpm --registry=https://registry.npm.taobao.org

# docker run -d --name gitlab-runner --restart always \
  #     -v /var/run/docker.sock:/var/run/docker.sock \
  #     -v /usr/bin/docker:/usr/bin/docker
  #     test:v1
