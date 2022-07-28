FROM icr.io/ibm-messaging/mq:latest

USER root
RUN microdnf install --nodocs java-1.8.0-openjdk-headless openssl make \
  && microdnf clean all

COPY src /src

ENTRYPOINT []
