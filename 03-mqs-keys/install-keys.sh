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
printf "$HIGHLIGHT_ON Generating keys for AMS encryption                                    $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

printf "$HIGHLIGHT_ON\n> Deleting previous MQS keys if found $HIGHLIGHT_OFF\n"
rm -rf $(pwd)/keys | indent

printf "$HIGHLIGHT_ON\n> Creating directories to store keys $HIGHLIGHT_OFF\n"
ALICE_DIR=$(pwd)/keys/alice 
BOB_DIR=$(pwd)/keys/bob

mkdir $(pwd)/keys | indent
mkdir $ALICE_DIR | indent
mkdir $BOB_DIR | indent

printf "$HIGHLIGHT_ON\n> Generate Alice keystore $HIGHLIGHT_OFF\n"
keytool -genkey -alias Alice_Java_Cert -keyalg RSA -keystore $ALICE_DIR/keystore.jks \
    -storepass passw0rd -dname "CN=alice, O=IBM, C=GB" -keypass passw0rd | indent

chmod +r $ALICE_DIR/keystore.jks | indent

echo "JKS.keystore = $ALICE_DIR/keystore
JKS.certificate = Alice_Java_Cert
JKS.encrypted = no
JKS.keystore_pass = passw0rd
JKS.key_pass = passw0rd
JKS.provider = IBMJCE" > $ALICE_DIR/keystore.conf | indent


printf "$HIGHLIGHT_ON\n> Generate Bob keystore $HIGHLIGHT_OFF\n"
keytool -genkey -alias Bob_Java_Cert -keyalg RSA -keystore $BOB_DIR/keystore.jks \
    -storepass passw0rd -dname "CN=bob, O=IBM, C=GB" -keypass passw0rd | indent

chmod +r $BOB_DIR/keystore.jks | indent

echo "JKS.keystore = $BOB_DIR/keystore
JKS.certificate = Bob_Java_Cert
JKS.encrypted = no
JKS.keystore_pass = passw0rd
JKS.key_pass = passw0rd
JKS.provider = IBMJCE" > $BOB_DIR/keystore.conf | indent


printf "$HIGHLIGHT_ON\n> Export Alice certificate $HIGHLIGHT_OFF\n"
keytool -exportcert -keystore $ALICE_DIR/keystore.jks -storepass passw0rd \
    -alias Alice_Java_Cert -file $ALICE_DIR/Alice_Java_Cert.cer | indent


printf "$HIGHLIGHT_ON\n> Import Alice certificate in Bob keystore $HIGHLIGHT_OFF\n"
keytool -importcert -file $ALICE_DIR/Alice_Java_Cert.cer -alias Alice_Java_Cert \
    -keystore $BOB_DIR/keystore.jks -storepass passw0rd | indent


printf "$HIGHLIGHT_ON\n> Export Bob certificate $HIGHLIGHT_OFF\n"
keytool -exportcert -keystore $BOB_DIR/keystore.jks -storepass passw0rd \
    -alias Bob_Java_Cert -file $BOB_DIR/Bob_Java_Cert.cer | indent


printf "$HIGHLIGHT_ON\n> Import Bob certificate in Alice keystore $HIGHLIGHT_OFF\n"
keytool -importcert -file $BOB_DIR/Bob_Java_Cert.cer -alias Bob_Java_Cert \
    -keystore $ALICE_DIR/keystore.jks -storepass passw0rd | indent

printf "$HIGHLIGHT_ON\n-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON MQS keys generated in the '03-mqs-keys/keys' directory                $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"