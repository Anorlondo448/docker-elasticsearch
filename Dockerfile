FROM elasticsearch:latest
MAINTAINER Anorlondo448 <@Anorlondo448>

ENV PATH /usr/share/elasticsearch/bin:$PATH

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

# recall default command as defined here https://github.com/docker-library/elasticsearch
CMD ["elasticsearch"]
