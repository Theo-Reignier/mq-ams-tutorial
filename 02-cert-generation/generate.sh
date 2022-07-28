#!/bin/bash

######################### EDIT VALUES BELOW ##########################

# Certificate information - Edit these variables to suit your project
export ORGANISATION=acmeinc
export COUNTRY=GB
export LOCALITY=Hursley
export STATE=Hampshire

#######################################################################

# allow this script to be run from other locations, despite the
#  relative file paths used in it
if [[ $BASH_SOURCE = */* ]]; then
  cd -- "${BASH_SOURCE%/*}/" || exit
fi

# indent command output
#   <command> | indent()
indent() { sed 's/^/  /'; }

# escape sequences for colouring headings in the
#  script output
HIGHLIGHT_ON="\033[1;32m"
HIGHLIGHT_OFF="\033[0m"

# Check for docker, alias to podman if doesn't exist
if ! command -v docker &> /dev/null
then
    echo "Docker not found, aliasing to podman for this script"
    shopt -s expand_aliases
    alias docker=podman
fi

printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Generating certificates for MQ                                        $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON\n> Exporting the required variables $HIGHLIGHT_OFF\n"
# Get the hostname for the OpenShift console using oc commands
consolehost=$(oc get route console -n openshift-console -ojsonpath='{.spec.host}')
openshifthost=${consolehost#*.}
export SAN_DNS="*.$openshifthost"
export COMMON_NAME="*.${openshifthost#*.}"

# Get the path to the `mq-demos` directory
export DEPLOYMENT_ROOT="$(pwd)/"

printf "$HIGHLIGHT_ON\n> Creating the 'certs' directory $HIGHLIGHT_OFF\n"
mkdir ${DEPLOYMENT_ROOT}/certs | indent

printf "$HIGHLIGHT_ON\n> Building the cert-generator image $HIGHLIGHT_OFF\n"
docker build --platform=linux/amd64 -t cert-generator docker | indent

printf "$HIGHLIGHT_ON\n> Running the cert-generator $HIGHLIGHT_OFF\n"
docker run --platform=linux/amd64 \
  -v ${DEPLOYMENT_ROOT}/certs:/certs \
  -w /certs \
  -e PREFIX=ams \
  -e COMMON_NAME=${COMMON_NAME} \
  -e SAN_DNS=${SAN_DNS} \
  -e ORGANISATION=${ORGANISATION} \
  -e COUNTRY=${COUNTRY} \
  -e LOCALITY=${LOCALITY} \
  -e STATE=${STATE} \
  cert-generator \
  make -f /src/Makefile | indent

docker run --platform=linux/amd64 \
  -v ${DEPLOYMENT_ROOT}/certs:/certs \
  -w /certs \
  cert-generator \
  openssl x509 \
  -in ams-mq-server.crt \
  -text \
  -noout | indent

printf "$HIGHLIGHT_ON\n-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON MQ certificates generated in the 'certs' directory                    $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
