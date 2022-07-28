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
printf "$HIGHLIGHT_ON Running the Putter app as the Alice user                              $HIGHLIGHT_OFF\n\n"
printf "$HIGHLIGHT_ON Putting a timestamp in the queue every 2 seconds                      $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON Press ^C to stop the Putter app                                       $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"

java -DMQS_KEYSTORE_CONF=./03-mqs-keys/keys/alice/keystore.conf \
  -cp ./05-mq-jms-app/jms-app/target/mq-jms-simple-0.0.1.jar com.ibm.clientengineering.mq.samples.Putter \
  | indent

printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON The Putter app has stopped running                                    $HIGHLIGHT_OFF\n"
printf "$HIGHLIGHT_ON-----------------------------------------------------------------------$HIGHLIGHT_OFF\n"