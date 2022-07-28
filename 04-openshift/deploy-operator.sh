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
printf "$HIGHLIGHT_ON Deploying IBM MQ operator on OpenShift                                $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON\n> Creating MQ namespace $HIGHLIGHT_OFF\n"
oc create namespace ams-mq --dry-run=client -o yaml | oc apply -f - | indent

printf "$HIGHLIGHT_ON\n> Creating a catalogue source for the MQ operator $HIGHLIGHT_OFF\n"
oc apply -f resources/catalogsource.yaml | indent

printf "> wait for the catalog pod to be created \n" | indent
PODS_COUNT="0"
while [ "$PODS_COUNT" = "0" ]
do
    PODS_COUNT=`oc get pods -l "olm.catalogSource=ibm-operator-catalog" -n openshift-marketplace --no-headers | wc -l | tr -d ' '`
    sleep 3
done

printf "> wait for the catalog pod to finish starting \n" | indent
POD_PHASE="Pending"
while [ "$POD_PHASE" = "Pending" ]
do
    POD_PHASE=`oc get pods -l "olm.catalogSource=ibm-operator-catalog" -n openshift-marketplace -ojsonpath='{.items[0].status.phase}'`
    sleep 10
done
if [ "$POD_PHASE" != "Running" ]; then
    printf "> ERROR: catalog pod failed to start \n"
    exit 1
fi

printf "$HIGHLIGHT_ON\n> Installing the MQ operator v2.0.0 $HIGHLIGHT_OFF\n"
oc apply -f resources/subscription.yaml | indent

printf "> wait for the MQ operator install plan to be created \n" | indent
CURRENT_CSV=""
while [ "$CURRENT_CSV" != "ibm-mq.v2.0.0" ]
do
    CURRENT_CSV=`oc get subscription ibm-mq -n openshift-operators -ojsonpath='{.status.currentCSV}'`
    INSTALL_PLAN=`oc get subscription ibm-mq -n openshift-operators -ojsonpath='{.status.installPlanRef.name}'`
done

printf "> wait for the MQ operator install plan to complete \n" | indent
INSTALL_PHASE="Installing"
while [ "$INSTALL_PHASE" = "Installing" ]
do
    INSTALL_PHASE=`oc get installplan $INSTALL_PLAN -n openshift-operators -ojsonpath='{.status.phase}'`
    sleep 10
done
if [ "$INSTALL_PHASE" != "Complete" ]; then
    printf "> ERROR: MQ operator install plan failed to complete \n"
    exit 1
fi

printf "> wait for the MQ operator installation to have succeeded \n" | indent
PHASE="Installing"
while [[ "$PHASE" =~ ^(Pending|InstallReady|Installing)$ ]]
do
    PHASE=`oc get ClusterServiceVersion ibm-mq.v2.0.0 -n ams-mq -ojsonpath='{.status.phase}'`
    sleep 10
done
if [ "$PHASE" != "Succeeded" ]; then
    printf "> ERROR: MQ operator installation was unsuccessful \n"
    exit 1
fi

printf "$HIGHLIGHT_ON\n-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON IBM MQ operator deployed on OpenShift                                 $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"