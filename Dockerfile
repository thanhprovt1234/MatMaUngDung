FROM maven:3.9-eclipse-temurin-22

WORKDIR /app

COPY pom.xml .
RUN mvn -q -DskipTests dependency:go-offline

COPY src ./src

RUN mkdir -p .local/tls && \
    keytool -genkeypair \
      -alias jetty \
      -keyalg RSA \
      -keysize 2048 \
      -storetype PKCS12 \
      -keystore .local/tls/jetty-keystore.p12 \
      -storepass changeit \
      -keypass changeit \
      -dname "CN=uteshop-web, OU=UTEShop, O=Local, L=Local, ST=Local, C=VN" \
      -validity 3650

EXPOSE 8081 8443

CMD ["mvn", "-DskipTests", "-Djetty.http.host=0.0.0.0", "-Djetty.https.host=0.0.0.0", "jetty:run"]
