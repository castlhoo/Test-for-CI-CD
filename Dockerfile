FROM openjdk:17-slim

COPY demo.jar /app/demo.jar

ENTRYPOINT ["java", "-jar", "/app/demo.jar"]

EXPOSE 8080
