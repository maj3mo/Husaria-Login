# StarLoco-Login — multi-stage build ze źródeł (MDE-18).
# Login = Java 8: kompilacja Gradlem na Temurin JDK 8, runtime na OpenJDK 11 JRE
# (Java 8 bytecode biega na 11 — tak samo robi oficjalny obraz StarLoco).

# ---- build stage: kompilacja fat-jara ze źródeł ----
# gradle:7.6.4-jdk8 = Gradle 7.6.4 + Temurin JDK 8 + git (build.gradle liczy
# 'version' przez `git rev-parse`, więc binarka git musi być obecna).
FROM gradle:7.6.4-jdk8 AS build
WORKDIR /src
COPY . .
# task `jar` produkuje fat-jar build/libs/login.jar (zależności z libs/ w środku)
RUN gradle --no-daemon jar

# ---- runtime stage ----
FROM alpine:latest
RUN apk add --no-cache openjdk11-jre
WORKDIR /app
COPY --from=build /src/build/libs/login.jar /app/login.jar
# domyślny config (w stacku i tak nadpisany bind-mountem z docker/config/)
COPY docker.config.properties /app/login.config.properties
CMD ["java", "-jar", "login.jar"]
