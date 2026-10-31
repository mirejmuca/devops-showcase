# ---- build stage ----
FROM eclipse-temurin:21-jdk AS build
WORKDIR /workspace
COPY .mvn .mvn
COPY mvnw pom.xml ./
RUN sh mvnw -B -q dependency:go-offline
COPY src src
RUN sh mvnw -B -q package -DskipTests

# ---- runtime stage ----
FROM eclipse-temurin:21-jre
RUN useradd --system --uid 1001 appuser
WORKDIR /app
COPY --from=build /workspace/target/*.jar app.jar
USER appuser
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]