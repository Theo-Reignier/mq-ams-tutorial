#!/bin/bash

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
printf "$HIGHLIGHT_ON Installing LDAP                                                       $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON\n> Creating LDAP namespace $HIGHLIGHT_OFF\n"
oc create namespace ldap-ams --dry-run=client -o yaml | oc apply -f - | indent

printf "$HIGHLIGHT_ON\n> Creating LDAP service accounts and permissions $HIGHLIGHT_OFF\n"
oc create serviceaccount ldapaccount -n ldap-ams --dry-run=client -o yaml | oc apply -f - | indent
oc adm policy add-scc-to-user privileged system:serviceaccount:ldap-ams:ldapaccount | indent
oc adm policy add-scc-to-user anyuid system:serviceaccount:ldap-ams:ldapaccount | indent

printf "$HIGHLIGHT_ON\n> Deploy LDAP config-map $HIGHLIGHT_OFF\n"
oc create configmap ldap-bootstrap --from-file=resources/ldap-config.ldif -n ldap-ams --dry-run=client -o yaml | oc apply -f - | indent

printf "$HIGHLIGHT_ON\n> Deploy LDAP server $HIGHLIGHT_OFF\n"
oc apply -f resources/ldap-deployment.yaml -n ldap-ams | indent

printf "$HIGHLIGHT_ON\n> Deploy LDAP service $HIGHLIGHT_OFF\n"
oc apply -f resources/ldap-service.yaml -n ldap-ams | indent

printf "$HIGHLIGHT_ON\n-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON LDAP service should be available on 'ldap-service.ldap-ams' port 389  $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

