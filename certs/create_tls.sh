## Please modify the script before running

SERVER_COMMON_NAME="Test Server CA"
CLIENT_COMMON_NAME="Test Client CA"
DOMAIN="api.example.com"
DAYS_CLIENT_CRT=365 # 1 year for client certificate
DAYS_CA=3650 # 10 years for CA

openssl req -newkey rsa:2048 -nodes -keyform PEM -keyout server-ca.key -x509 -days $DAYS_CA -outform PEM -out server-ca.crt -subj "/CN=$SERVER_COMMON_NAME"

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -subj "/CN=$DOMAIN"
openssl x509 -req -in server.csr -CA server-ca.crt -CAkey server-ca.key -set_serial 100 -days 365 -outform PEM -out server.crt

openssl req -newkey rsa:2048 -nodes -keyform PEM -keyout client-ca.key -x509 -days $DAYS_CA -outform PEM -out client-ca.crt -subj "/CN=$CLIENT_COMMON_NAME"
openssl genrsa -out client.key 2048

openssl req -new -key client.key -out client.csr -subj "/CN=Test Client"
openssl x509 -req -in client.csr -CA client-ca.crt -CAkey client-ca.key -set_serial 101 -days $DAYS_CLIENT_CRT -outform PEM -out client.crt
