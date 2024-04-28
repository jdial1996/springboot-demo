# Stage 1: Build Spring Boot app using JDK 21
FROM ubuntu:22.04 as builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y openjdk-21-jdk \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64

ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle . 
COPY settings.gradle .

COPY src src

RUN chmod +x ./gradlew

RUN ./gradlew build

# Stage 2: Create the runtime image
FROM ubuntu:22.04

RUN apt-get update \
    && apt-get install -y openjdk-21-jdk-headless \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
ENV PATH="$JAVA_HOME/bin:$PATH"

WORKDIR /app

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

CMD ["java", "-jar", "app.jar"]