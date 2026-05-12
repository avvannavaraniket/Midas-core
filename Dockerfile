# syntax=docker/dockerfile:1
# -----------------------------------------------------------------------------
# Stage 1 — build the fat JAR with Maven (JDK 17 matches pom.xml java.version).
# Stage 2 — run only the JRE + JAR (smaller attack surface, smaller image).
# -----------------------------------------------------------------------------

FROM maven:3.9.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Layer cache: resolve dependencies before copying all sources.
COPY pom.xml .
RUN mvn -q -B dependency:go-offline

COPY src ./src
RUN mvn -q -B -DskipTests package

# -----------------------------------------------------------------------------
# Runtime: Eclipse Temurin JRE 17 on Alpine (common production choice).
# -----------------------------------------------------------------------------
FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app

RUN addgroup -S spring && adduser -S spring -G spring

COPY --from=build --chown=spring:spring /app/target/midascore-*.jar /app/app.jar

USER spring:spring

EXPOSE 33400

# Container-aware defaults; Compose overrides via environment.
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0"

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar /app/app.jar"]
