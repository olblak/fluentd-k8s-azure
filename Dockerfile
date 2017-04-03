FROM alpine:3.4

ENV \
  FLUENTD_PROJECT="https://github.com/fluent/fluentd" \
  PROJECT="https://github.com/olblak/fluentd-k8s-azure"

ARG FLUENTD_VERSION="0.14.14"

LABEL \
    Description="Fluentd docker image used to send logs on log analytics" \
    Fluentd_version=$FLUENTD_VERSION \
    Fluentd_Project=$FLUENTD_PROJECT \
    Project=$PROJECT \
    Maintainer="Olblak <me@olblak.com>"


# Do not split this into multiple RUN!
# Docker creates a layer for every RUN-Statement
# therefore an 'apk delete build*' has no effect
RUN apk --no-cache add \
                   build-base \
                   ca-certificates \
                   ruby \
                   ruby-irb \
                   zlib-dev \
                   ruby-dev && \
    echo 'gem: --no-document' >> /etc/gemrc && \
    gem install oj && \
    gem install json && \
    gem install fluentd -v $FLUENTD_VERSION && \
    gem install fluent-plugin-rewrite-tag-filter && \
    gem install fluent-plugin-kubernetes_metadata_filter && \
    gem install fluent-plugin-azure-loganalytics && \
    gem install fluent-plugin-forest && \
    apk del build-base ruby-dev zlib-dev && \
    rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN adduser -D -g '' -u 1000 -h /home/fluent fluent

# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc /fluentd/plugins /fluentd/log /fluentd/tmp

# Upload fluentd configuration files
COPY etc /fluentd/etc

COPY entrypoint.sh /fluentd/entrypoint.sh
RUN chmod 0700 /fluentd/entrypoint.sh
RUN chown -R fluent:fluent /fluentd

#USER fluent
WORKDIR /home/fluent

# Tell ruby to install packages as user
RUN echo "gem: --user-install --no-document" >> ~/.gemrc
ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH
ENV GEM_PATH /home/fluent/.gem/ruby/2.3.0:$GEM_PATH

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

ENTRYPOINT ["/fluentd/entrypoint.sh"]
