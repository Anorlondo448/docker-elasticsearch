FROM docker.elastic.co/elasticsearch/elasticsearch-alpine-base:latest
MAINTAINER Anorlondo448 <@Anorlondo448>

ENV ELASTIC_VERSION=5.1.2
ENV ES_DOWNLOAD_URL=https://artifacts.elastic.co/downloads/elasticsearch
ENV PATH /usr/share/elasticsearch/bin:$PATH
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV ES_HOME /usr/share/elasticsearch

WORKDIR ${ES_HOME}

# Download/extract defined ES version. busybox tar can't strip leading dir.
RUN wget ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    EXPECTED_SHA=$(wget -O - ${ES_DOWNLOAD_URL}/elasticsearch-${ELASTIC_VERSION}.tar.gz.sha1) && \
    test $EXPECTED_SHA == $(sha1sum elasticsearch-${ELASTIC_VERSION}.tar.gz | awk '{print $1}') && \
    tar zxf elasticsearch-${ELASTIC_VERSION}.tar.gz && \
    chown -R elasticsearch:elasticsearch elasticsearch-${ELASTIC_VERSION} && \
    mv elasticsearch-${ELASTIC_VERSION}/* . && \
    rmdir elasticsearch-${ELASTIC_VERSION} && \
    rm elasticsearch-${ELASTIC_VERSION}.tar.gz

RUN set -ex && for esdirs in config data logs; do \
        mkdir -p "$esdirs"; \
        chown -R elasticsearch:elasticsearch "$esdirs"; \
    done

USER elasticsearch

# Install xpack
RUN elasticsearch-plugin install --batch x-pack

# install icu
RUN elasticsearch-plugin install analysis-icu

# install kuromoji
RUN elasticsearch-plugin install analysis-kuromoji

# install smartcn
RUN elasticsearch-plugin install analysis-smartcn

# install phonetic
RUN elasticsearch-plugin install analysis-phonetic

COPY elasticsearch.yml ${ES_HOME}/config/
COPY log4j2.properties ${ES_HOME}/config/
COPY bin/es-docker ${ES_HOME}/bin/es-docker

USER root
RUN chown elasticsearch:elasticsearch ${ES_HOME}/config/elasticsearch.yml \
                                      ${ES_HOME}/config/log4j2.properties \
                                      ${ES_HOME}/bin/es-docker && \
    chmod 0750 ${ES_HOME}/bin/es-docker

USER elasticsearch
CMD ["/bin/bash", "${ES_HOME}/bin/es-docker"]

EXPOSE 9200 9300
