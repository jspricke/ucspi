# this Makefile creates files which are needed for tests

KEYLEN=4096

test: tcps tcpc tlss tlsc server.crt client.crt ca.crt
	./test.sh

# create server key ############################################################
client.key:
	openssl genrsa -out $@ ${KEYLEN}
# create server certificate request
client.csr: client.key client.cf
	openssl req -new -key client.key -config client.cf -out $@
# create ca-signed server certificate
client.crt: client.csr ca.crt
	openssl x509 -req -in client.csr -out $@ \
	    -CAcreateserial -CAkey ca.key -CA ca.crt
# create pkcs12 version of the client key for import browser
client.p12: client.crt client.key
	openssl pkcs12 -export -clcerts -in client.crt -inkey client.key -out $@

# create server key ############################################################
server.key:
	openssl genrsa -out $@ ${KEYLEN}
# create server certificate request
server.csr: server.key server.cf
	openssl req -new -key server.key -config server.cf -out $@
# create ca-signed server certificate
server.crt: server.csr ca.crt
	openssl x509 -req -in server.csr -out $@ \
	    -CAcreateserial -CAkey ca.key -CA ca.crt

# create certificate authority #################################################
ca.key:
	openssl genrsa -out $@ ${KEYLEN}
ca.crt: ca.key ca.cf
	openssl req -new -x509 -key ca.key -config ca.cf -out $@

# create certificate revocation list ###########################################
ca.crl: ca.cf ca.key client_revoke.crt
	openssl ca -config ca.cf -gencrl -revoke client_revoke.crt -out $@

# create client revoke key #####################################################
client_revoke.key:
	openssl genrsa -out $@ ${KEYLEN}
# create server certificate request
client_revoke.csr: client_revoke.key client_revoke.cf
	openssl req -new -key client_revoke.key -config client_revoke.cf -out $@
# create ca-signed server certificate
client_revoke.crt: client_revoke.csr ca.crt
	openssl x509 -req -in client_revoke.csr -out $@ \
	    -CAcreateserial -CAkey ca.key -CA ca.crt
# create pkcs12 version of the client_revoke key for import browser
client_revoke.p12: client_revoke.crt client_revoke.key
	openssl pkcs12 -export -clcerts -in client_revoke.crt \
	    -inkey client_revoke.key -out $@
