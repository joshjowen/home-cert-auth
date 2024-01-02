#!/bin/bash
set -e

SU_PREFIX=""

if [ "$EUID" -ne 0 ]
then 
    SU_PREFIX="sudo "
fi

# Install Deps
${SU_PREFIX}apt-get install -y openssl

# Change to the output path
SCRIPT_PATH=$(dirname `realpath $0`)
cd $SCRIPT_PATH
mkdir -p ca_certificate
cd ca_certificate

# Generate the CA key files
openssl genrsa -des3 -out CA.key 2048
openssl req -x509 -new -nodes -key CA.key -sha256 -days 1825 -out CA.pem
