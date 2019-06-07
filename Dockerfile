# Build Stage
FROM lacion/alpine-golang-buildimage:1.12.4 AS build-stage

LABEL app="build-MigrateS3Buckets"
LABEL REPO="https://github.com/joeydumont/MigrateS3Buckets"

ENV PROJPATH=/go/src/github.com/joeydumont/MigrateS3Buckets

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/joeydumont/MigrateS3Buckets
WORKDIR /go/src/github.com/joeydumont/MigrateS3Buckets

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/joeydumont/MigrateS3Buckets"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/MigrateS3Buckets/bin

WORKDIR /opt/MigrateS3Buckets/bin

COPY --from=build-stage /go/src/github.com/joeydumont/MigrateS3Buckets/bin/MigrateS3Buckets /opt/MigrateS3Buckets/bin/
RUN chmod +x /opt/MigrateS3Buckets/bin/MigrateS3Buckets

# Create appuser
RUN adduser -D -g '' MigrateS3Buckets
USER MigrateS3Buckets

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/MigrateS3Buckets/bin/MigrateS3Buckets"]
