FROM alpine:3.4
MAINTAINER VERNIN Olivier <olivier@vernin.me>

LABEL \
    Description="Fluentd docker image for jenkins infra" \
    Fluentd_version="0.14.11" \
    log_type="stream"


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
    gem install fluentd -v 0.14.11 && \
    gem install fluent-plugin-rewrite-tag-filter && \
    gem install fluent-plugin-kubernetes_metadata_filter && \
    gem install fluent-plugin-azure-loganalytics && \
    #gem install fluent-plugin-azurestorage && \
    #gem install fluent-plugin-forest && \
    gem install fluent-plugin-forest
    #apk del build-base ruby-dev zlib-dev && \
   # rm -rf /tmp/* /var/tmp/* /usr/lib/ruby/gems/*/cache/*.gem

RUN adduser -D -g '' -u 1000 -h /home/fluent fluent

# configuration/plugins path (default: copied from .)
RUN mkdir -p /fluentd/etc /fluentd/plugins /fluentd/log

# Upload fluentd configuration files
COPY etc /fluentd/etc

COPY entrypoint.sh /fluentd/entrypoint.sh
RUN chmod 0700 /fluentd/entrypoint.sh
RUN chown -R fluent:fluent /fluentd

# Install fluent-plugin-azurestorage 
ADD https://github.com/htgc/fluent-plugin-azurestorage/archive/v0.0.8.tar.gz /fluentd/plugins/fluent-plugin-azurestorage-v0.0.8.tar.gz
RUN apk --no-cache  add git ruby-bundler && \
    gem install gemspec io-console && \
    tar xvzf /fluentd/plugins/fluent-plugin-azurestorage-v0.0.8.tar.gz -C /fluentd/plugins/ && \
    cd /fluentd/plugins/fluent-plugin-azurestorage-0.0.8 && \
    bundle install && \
    rake build

RUN cd /fluentd/plugins/fluent-plugin-azurestorage-0.0.8 && \
    rake build

RUN cd /fluentd/plugins/fluent-plugin-azurestorage-0.0.8 && \
    rake install

#USER fluent
WORKDIR /home/fluent

# Tell ruby to install packages as user
RUN echo "gem: --user-install --no-document" >> ~/.gemrc
ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH
ENV GEM_PATH /home/fluent/.gem/ruby/2.3.0:$GEM_PATH

ENV FLUENTD_OPT=""
ENV FLUENTD_CONF="fluent.conf"

ENTRYPOINT ["/fluentd/entrypoint.sh"]

