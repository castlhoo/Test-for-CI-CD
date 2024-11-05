FROM openjdk:17-jre-slim

COPY demo.jar /app/demo.jar

ENTRYPOINT ["java", "-jar", "/app/demo.jar"]

EXPOSE 8081
