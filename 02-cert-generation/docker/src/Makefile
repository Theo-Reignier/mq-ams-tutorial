.PHONY: all clean

all: ams-ca ams-mq-server ams-client

ams-ca: ORGANISATION_UNIT = ${ORGANISATION}_CA
ams-ca: ams-ca.key ams-ca.crt ams-ca.jks

ams-mq-server: ORGANISATION_UNIT = ${ORGANISATION}_MQ
ams-mq-server: ams-mq-server.key ams-mq-server.crt

ams-client: ORGANISATION_UNIT = ${ORGANISATION}_CLIENT
ams-client: ams-client.key ams-client.crt ams-client.jks

clean:
	rm -f ams-mq-server.key ams-mq-server.crt
	rm -f ams-client.key ams-client.crt ams-client.jks
	rm -f ams-ca.key ams-ca.crt ams-ca.jks ams-ca.srl

ams-ca.key:
	openssl genrsa \
		-des3 \
		-passout pass:passw0rd \
		-out ams-ca.key 4096

ams-ca.crt: ams-ca.key
	openssl req \
		-x509 \
		-new \
		-sha256 \
		-key ams-ca.key \
		-passin pass:passw0rd \
		-days 365 \
		-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANISATION}/OU=${ORGANISATION_UNIT}/CN=${COMMON_NAME}" \
		-out ams-ca.crt

ams-ca.jks: ams-ca.crt
	rm -f ams-ca.jks
	keytool -keystore ams-ca.jks \
		-deststorepass passw0rd \
		-storetype jks \
		-importcert \
		-file ams-ca.crt \
		-alias ca-certificate \
		-noprompt

%.key:
	openssl genrsa -out $@ 2048

%.csr: %.key
	openssl req \
		-new \
		-sha256 \
		-key $< \
		-subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCALITY}/O=${ORGANISATION}/OU=${ORGANISATION_UNIT}/CN=${COMMON_NAME}" \
		-sha256 \
		-out $@

%.crt: %.csr ams-ca.crt ams-ca.key
	openssl x509 \
		-req \
		-sha256 \
		-in $< \
		-extfile /src/san.ext \
		-CA ams-ca.crt \
		-CAkey ams-ca.key \
		-CAcreateserial \
		-passin pass:passw0rd \
		-days 365 \
		-sha256 \
		-out $@

%.p12: %.crt %.key
	openssl pkcs12 -export \
		-in $(basename $@).crt \
		-inkey $(basename $@).key \
		-out $@ \
		-passout pass:passw0rd \
		-name $(basename $@)-pkcs12

%.jks: %.p12
	rm -f $@
	keytool -importkeystore \
		-deststorepass passw0rd \
		-destkeypass passw0rd \
		-destkeystore $@ \
		-srckeystore $(basename $@).p12 \
		-srcstoretype PKCS12 \
		-srcstorepass passw0rd \
		-alias $(basename $@)-pkcs12
