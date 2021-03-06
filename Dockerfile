FROM debian AS builder

ENV APPD_AGENT_VERSION="4.5.19.29348"
ENV APPD_AGENT_SHA256="245fc140fdc619a5375012651f94ab4711a64b6e5ab9908e35fef56f082882c7"

RUN apt-get update \
    && apt-get install -y --no-install-recommends  unzip \
    && apt-get install -y wget \
	&& rm -rf /var/lib/apt/lists/*

COPY AppServerAgent-${APPD_AGENT_VERSION}.zip /
RUN echo "${APPD_AGENT_SHA256} *AppServerAgent-${APPD_AGENT_VERSION}.zip" >> appd_checksum \
    && sha256sum -c appd_checksum \
    && rm appd_checksum \
    && unzip -oq AppServerAgent-${APPD_AGENT_VERSION}.zip -d /tmp

RUN wget -O /dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
RUN chmod +x /dumb-init

COPY init-scripts/ /init-scripts
COPY entrypoint.sh /entrypoint.sh
COPY run-java.sh /run-java.sh

FROM openjdk:11-jdk-slim
COPY --from=builder /tmp /opt/appdynamics
COPY --from=builder /init-scripts /init-scripts
COPY --from=builder /entrypoint.sh /entrypoint.sh
COPY --from=builder /run-java.sh /run-java.sh
COPY --from=builder /dumb-init /dumb-init

RUN apt-get update && apt-get install -y wget locales

RUN sed -i -e 's/# nb_NO.UTF-8 UTF-8/nb_NO.UTF-8 UTF-8/' /etc/locale.gen && locale-gen
ENV LC_ALL="nb_NO.UTF-8"
ENV LANG="nb_NO.UTF-8"
ENV TZ="Europe/Oslo"
ENV APP_BINARY=app
ENV APP_JAR=app.jar
ENV MAIN_CLASS="Main"
ENV CLASSPATH="/app/WEB-INF/classes:/app/WEB-INF/lib/*"

WORKDIR /app

EXPOSE 8080

ENTRYPOINT ["/dumb-init", "--", "/entrypoint.sh"]

ARG app_name

ENV APPD_ENABLED=true
ENV JAVA_OPTS="${JAVA_OPTS} -XX:MaxRAMPercentage=65.0"

COPY build/libs/*.jar app.jar
