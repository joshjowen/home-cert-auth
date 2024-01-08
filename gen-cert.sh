#!/bin/bash
set -e

if [ ! -z "$1" ]
then
    DOMAIN_NAME="$1"
else
    echo "Usage: $0 <domain>"
fi

# Change to the output path
SCRIPT_PATH=$(dirname `realpath $0`)
if [ ! -e "${SCRIPT_PATH}/ca_certificate/CA.pem" ]
then
    echo "The CA certificates aren't available. Did you run the Setup script first?"
    exit -1
fi

cd ${SCRIPT_PATH}
mkdir -p site_certs/${DOMAIN_NAME}
cd site_certs/${DOMAIN_NAME}

openssl genrsa -out ${DOMAIN_NAME}.key 2048
openssl req -new -key ${DOMAIN_NAME}.key -out ${DOMAIN_NAME}.csr


cat <<EOF > ${DOMAIN_NAME}.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = ${DOMAIN_NAME}
DNS.2 = *.${DOMAIN_NAME}
EOF


openssl x509 -req -in ${DOMAIN_NAME}.csr -CA ${SCRIPT_PATH}/ca_certificate/CA.pem -CAkey ${SCRIPT_PATH}/ca_certificate/CA.key \
    -CAcreateserial -out ${DOMAIN_NAME}.crt -days 825 -sha256 -extfile ${DOMAIN_NAME}.ext
