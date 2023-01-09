FROM quay.io/keycloak/keycloak:20.0.1 as keycloak

RUN keytool -genkeypair -storepass password -storetype PKCS12 -keyalg RSA -keysize 2048 -dname "CN=server" -alias server -ext "SAN:c=DNS:localhost,IP:127.0.0.1" -keystore /opt/keycloak/conf/server.keystore
RUN /opt/keycloak/bin/kc.sh build
COPY keycloak-dev.conf /keycloak-dev.conf

RUN mkdir "/opt/keycloak/data/import"
COPY dams-local-dev-realm.json /opt/keycloak/data/import/dams-local-dev-realm.json

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]