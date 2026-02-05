# Сборка приложения - ИСПОЛЬЗУЕМ ARM64 ОБРАЗ ДЛЯ Maven
FROM arm64v8/maven:3.8.6-openjdk-8 AS build
WORKDIR /app
# Копируем файлы проекта
COPY pom.xml .
COPY src ./src
# Собираем приложение
RUN mvn clean package -DskipTests -B --no-transfer-progress

# Финальный образ - ДЛЯ ARM64
FROM arm64v8/openjdk:8-jre-alpine

WORKDIR /app
# Копируем собранный JAR из этапа сборки
COPY --from=build /app/target/*.jar app.jar
# Копируем и настраиваем wait-for-it скрипт
COPY wait-for-it.sh /app/wait-for-it.sh
RUN apk add --no-cache bash && chmod +x /app/wait-for-it.sh
# Открываем порт сервиса
EXPOSE 8085
# Запускаем с ожиданием PostgreSQL (исправлен синтаксис)
ENTRYPOINT ["/bin/sh", "-c", "/app/wait-for-it.sh postgres:5432 -- java -jar app.jar"]