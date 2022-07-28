#!/bin/bash -e

# exit when any command fails
set -e

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

printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Deploying MQ queue manager on OpenShift                               $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

# check that we have an entitlement key that we can put in a secret
if [[ -z "$IBM_ENTITLEMENT_KEY" ]]; then
    echo "You must set an IBM_ENTITLEMENT_KEY environment variable" 1>&2
    echo "Create your entitlement key at https://myibm.ibm.com/products-services/containerlibrary" 1>&2
    echo "Set it like this:" 1>&2
    echo " export IBM_ENTITLEMENT_KEY=..." 1>&2
    exit 1
fi

printf "$HIGHLIGHT_ON\n> Creating MQ namespace $HIGHLIGHT_OFF\n"
oc create namespace ams-mq --dry-run=client -o yaml | oc apply -f - | indent

printf "$HIGHLIGHT_ON\n> Creating IBM entitlement key $HIGHLIGHT_OFF\n"
oc create secret docker-registry ibm-entitlement-key \
    --docker-username=cp \
    --docker-password=$IBM_ENTITLEMENT_KEY \
    --docker-server=cp.icr.io \
    --namespace=ams-mq --dry-run=client -o yaml | oc apply -f - | indent

printf "$HIGHLIGHT_ON\n> Creating MQ certificate secrets $HIGHLIGHT_OFF\n"
oc create secret tls mq-server-tls \
    --key="../02-cert-generation/certs/ams-mq-server.key" \
    --cert="../02-cert-generation/certs/ams-mq-server.crt" \
    -n ams-mq --dry-run=client -o yaml | oc apply -f - | indent

oc create secret generic mq-ca-tls \
    --from-file=ca.crt="../02-cert-generation/certs/ams-ca.crt" \
    -n ams-mq --dry-run=client -o yaml | oc apply -f - | indent

printf "$HIGHLIGHT_ON\n> Creating Queue Manager config-map $HIGHLIGHT_OFF\n"
oc apply -f resources/qmgr-config.yaml -n ams-mq | indent

printf "$HIGHLIGHT_ON\n> Creating MQ route $HIGHLIGHT_OFF\n"
oc apply -f resources/route.yaml -n ams-mq | indent

printf "$HIGHLIGHT_ON\n> Creating Queue Manager $HIGHLIGHT_OFF\n"
oc apply -f resources/qmgr.yaml -n ams-mq | indent

printf "> wait for the queue manager to start running \n" | indent
PHASE="Pending"
while [ "$PHASE" != "Running" ]
  do
      PHASE=`oc get queuemanager -n ams-mq ams-qmgr -o jsonpath='{.status.phase}'`
      sleep 10
  done

printf "$HIGHLIGHT_ON\n-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON MQ queue manager successfully deployed on OpenShift                   $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"