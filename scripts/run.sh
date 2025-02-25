#!/bin/sh
set +x

# Parameters:
# $1: Path to the new truststore
# $2: Truststore password
# $3: Public key to be imported
# $4: Alias of the certificate
function create_truststore {
   keytool -keystore $1 -storepass $2 -noprompt -alias $4 -import -file $3 -storetype PKCS12
}

# Parameters:
# $1: Path to the new keystore
# $2: Truststore password
# $3: Public key to be imported
# $4: Private key to be imported
# $5: Alias of the certificate
function create_keystore {
   RANDFILE=/tmp/.rnd openssl pkcs12 -export -in $3 -inkey $4 -name $HOSTNAME -password pass:$2 -out $1
}

if [ "$CA_CRT" ];
then
    echo "Preparing truststore"


    echo "$CA_CRT" > /tmp/ca.crt

    create_truststore /tmp/truststore.p12 $TRUSTSTORE_PASSWORD /tmp/ca.crt ca
    
    mv /tmp/truststore.p12 ${TRUSTSTORE_FILE:-/tls-certs/truststore.p12}
fi

if [[ "$USER_CRT" && "$USER_KEY" ]];
then
    echo "Preparing keystore"


    echo "$USER_CRT" > /tmp/user.crt
    echo "$USER_KEY" > /tmp/user.key

    create_keystore /tmp/keystore.p12 $KEYSTORE_PASSWORD /tmp/user.crt /tmp/user.key /opt/kafka/cluster-certs/cluster-ca.crt $HOSTNAME
    
    mv /tmp/keystore.p12 ${KEYSTORE_FILE:-/tls-certs/keystore.p12}
fi

exit 0
