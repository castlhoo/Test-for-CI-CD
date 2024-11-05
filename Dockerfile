FROM openjdk:17-slim

COPY demo.jar /app/demo-0.0.1-SNAPSHOT.jar

ENTRYPOINT ["java", "-jar", "/app/demo-0.0.1-SNAPSHOT.jar"]

EXPOSE 8080
